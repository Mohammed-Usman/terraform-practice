import os
import zipfile


def create_lambda_zip(lambda_folder):
    lambda_file = os.path.join(lambda_folder, "lambda_function.py")

    if not os.path.exists(lambda_file):
        print(f"Error: {lambda_file} not found.")
        return

    zip_file_name = "lambda_function.zip"
    zip_file_path = os.path.join(lambda_folder, zip_file_name)

    with zipfile.ZipFile(zip_file_path, 'w') as lambda_zip:
        lambda_zip.write(lambda_file, "lambda_function.py")

    print(f"ZIP file created: {zip_file_path}")


def create_all_lambda_zips(root_folder):
    lambdas_folder = os.path.join(root_folder, "Lambdas")

    for lambda_folder in os.listdir(lambdas_folder):
        lambda_folder_path = os.path.join(lambdas_folder, lambda_folder)
        # print(lambda_folder_path)

        if os.path.isdir(lambda_folder_path):
            create_lambda_zip(lambda_folder_path)


if __name__ == "__main__":
    root_folder = ".."  # Replace with the actual path to your Test folder
    create_all_lambda_zips(root_folder)
