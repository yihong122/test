WITH top_5_users AS (
    SELECT * FROM (
        SELECT 
            r.user_id,
            COUNT(*) AS recipe_count
        FROM recipe AS r
        GROUP BY r.user_id
        ORDER BY recipe_count DESC
        LIMIT 5
    )
),
recipe_likes AS (
    SELECT 
        rl.recipe_id,
        COUNT(*) AS like_count
    FROM recipe_like AS rl
    GROUP BY rl.recipe_id
),
likes_topuser AS (
    SELECT 
        r.recipe_id,
        r.user_id,
        r.title_zh_tw,
        r.posted_dt,
        COALESCE(rl.like_count, 0) AS like_count
    FROM recipe AS r
    LEFT JOIN recipe_likes AS rl ON r.recipe_id = rl.recipe_id
    WHERE r.user_id IN (SELECT user_id FROM top_5_users)
),
ranked_likes AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY like_count DESC) AS rn
    FROM likes_topuser
)
SELECT 
    u.first_name,
    u.last_name,
    u.email,
    t.recipe_count as "Number of recipe posted",
    r.recipe_id as "Recipe ID with most like",
    r.title_zh_tw,
    r.posted_dt,
    r.like_count
FROM ranked_likes AS r
JOIN "users" AS u ON r.user_id = u.user_id JOIN top_5_users AS t ON r.user_id = t.user_id
WHERE r.rn = 1
order by t.recipe_count desc;
