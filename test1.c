int main() {
    int a,b;

    a = 3;
    b = a + 2;

    if (a < b)
        b = b * 2;

    return b;
}

// ./parser < test1.c 로 테스트 코드 실행해보기.