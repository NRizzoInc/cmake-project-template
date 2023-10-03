#include <iostream>

#include <version.h>

int main() {
    std::cout << "GIT_SHA1=" << GIT_SHA1 << "\n";
    std::cout << "GIT_BRANCH=" << GIT_BRANCH << "\n";
    return EXIT_SUCCESS;
}
