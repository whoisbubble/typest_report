def authenticate(username: str, token: str) -> bool:
    """Проверка токена пользователя."""
    if not username or not token:
        return False
    return token.startswith("Bearer ")

if __name__ == "__main__":
    user = "student"
    demo_token = "Bearer secret123"
    print(f"Auth result: {authenticate(user, demo_token)}")
