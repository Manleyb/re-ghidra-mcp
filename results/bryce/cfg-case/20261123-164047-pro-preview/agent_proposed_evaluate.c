
int evaluate(char *expr) {
    int result = 0;
    int current_val = 0;
    char op = '+';
    int i = 0;
    
    // FUN_001022d6 fetches expr[i] based on loop condition
    while (expr[i] != '\0') {
        // Obfuscated block performing SUB EAX, 0x30 and CMP bounds
        if (expr[i] >= '0' && expr[i] <= '9') {
            current_val = (current_val * 10) + (expr[i] - '0');
        } else {
            // Apply previous operator
            if (op == '+') result += current_val;
            else if (op == '-') result -= current_val;
            else if (op == '*') result *= current_val;
            else if (op == '/') result /= current_val;
            
            current_val = 0;
            op = expr[i]; // Store new operator
        }
        i++;
    }
    
    // Apply final operator
    if (op == '+') result += current_val;
    else if (op == '-') result -= current_val;
    else if (op == '*') result *= current_val;
    else if (op == '/') result /= current_val;
    
    return result;
}
