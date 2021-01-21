## Benchmarks
"champion.json hash: 6.3e-06"
"condensed hash: 1.8e-06"

## Explanation
The main function of the Champion class is to convert champion names to ids and vice versa. Since it's conceivable for many requests to happen in a short time, it would be ideal for the per request calculation to be as simplistic as possible.

In the above benchmarks, the condensed hash contains only the champion name and the champion id as an int, while the original hash contains all the information loaded from champion.json. The resulting times are displayed in seconds.

As you can see, the original hash takes 250% longer to calculate a name from an id than the condensed hash. The tradeoff is that the server takes a longer amount of time of similar magnitude to start up and reload updates, due to having to create the condensed hash. Safe to say a worthwhile trade.
