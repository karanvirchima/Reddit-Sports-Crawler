# CS172 Project - Reddit
https://www.cs.ucr.edu/~vagelis/classes/CS172/Course%20Project.htm

## How to Run the Bash Script file
  - This will run on the terminal assuming that it is compatible with python3

### 1. In order to gain access to the Reddit API, the program requires the client ID and client secret to be provided in the credentials.txt file. Please replace the placeholder text [client_id] and [client_secret] with your unique credentials, respectively, before running the program.

![image](https://user-images.githubusercontent.com/78754250/235325629-b2cb3cdf-08e9-42b9-8c2f-f92ad0a072dc.png)

### 2. Insert some subreddit names in the seeds.txt file
  - They only need to be the subreddit names in a list, look at the picture below for an example
  - Important: If the subreddits names are not public or was deleted, the code will run into an Exception error

![image](https://user-images.githubusercontent.com/78754250/235325841-69ed2ebd-6aea-4855-856d-3d366f1f9075.png)

### 3. Run these two commands in the directory with these files
  - chmod +x python3.sh
  - python3 python3.sh [#] [File_Name] [@]
    - Replace [#] with the number of the amount of data you want to crawl in MB until the program ends
      ### Important:
        - The amount of data is compared to the size of [File_Name], not the amount of data you crawled from a subreddit
        - The size of the file is compared after the program completes crawling a subreddit, not during
    - Replace [File_Name] with the name of the .json file you want to add the crawled reddit data to
      - It can be either an already existing file or not
        - Probably best to use *FirstName-LastName* as [File_Name] to know who crawled which file
    - Replace [@] with the number of subreddits you want to crawl in the seeds.txt file
      - This will stop running the program after it finishes crawling the subreddit and storing the data in a json file
    - Here is an example of running the command:
      - python3 python3.sh 100 Alex-Ramos 10
        - This creates a file Alex-Ramos.json file and keeps crawling subreddit data into Alex-Ramos.json file
            - The program stops when Alex-Ramos.json file reaches at least 100 MB, if it finishes crawling 10 subreddits, or if the seeds.txt file is empty
          - It can be more than 10 MB as it checks file size after it finished crawling the current subreddit
  - Note: The program adds all the data gathered from a subreddit after it finishes crawling that subreddit and updates the crawled and seeds text file accordingly
    - If you stop the program before a subreddit finishes being crawled, you will have to recrawl that subreddit as it will not be added to the json
    - It will also not display the total number of posts you crawled in that run or the size of the json file
  
### 4. After you are done
  ### Important
  - It is crucial to remove the sensitive information of the client ID and client secret from the 'credentials.txt' file to prevent unauthorized access
  - This program does not support parallel execution. Therefore, in situations where multiple users are simultaneously crawling subreddits using this program, the possibility of running duplicate subreddits cannot be ruled out

### Notes
  - The program prints the name of the subreddit currently being crawled and when it starts crawling in New, Hot, and Top posts.
    - This enables users to monitor the program's progress and status throughout the execution process
  - Upon completion of the program execution, the number of crawled posts is printed
  - The program also reports the size of the resulting JSON file, denoted by '[File_Name].json', in bytes
