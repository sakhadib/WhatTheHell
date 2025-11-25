def deep_function_level_5():
    # This will cause an AttributeError
    result = "hello".some_nonexistent_method()
    return result

def deep_function_level_4():
    data = [1, 2, 3, 4, 5]
    processed = deep_function_level_5()
    return processed

def deep_function_level_3():
    matrix = [[1, 2], [3, 4]]
    result = deep_function_level_4()
    return result

def deep_function_level_2():
    x = 10
    y = 20
    z = deep_function_level_3()
    return z

def deep_function_level_1():
    config = {"setting": "value"}
    output = deep_function_level_2()
    return output

def main():
    print("Starting deep calculation...")
    result = deep_function_level_1()
    print(f"Result: {result}")

if __name__ == "__main__":
    main()
