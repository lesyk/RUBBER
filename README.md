![alt text](https://github.com/lesyk/RUBBER/blob/master/RUBBER/logo.JPG)
## RUBBER
My first OS X app. Developed during #UBERHACKCPH, thx Uber for opportunity and t-shirts. [Download link](https://github.com/lesyk/RUBBER/tree/master/RUBBER/RUBBER.app)


Shows time when next busses come to stations around your location together with Uber expected pick up time.

Since Google Maps does not provide API for public transportation, I hacked it a bit. App tries to build routes from current location to places around (literally around), with increasing distance from location. As a result, I am getting all stations arount together with busses.

![alt text](https://github.com/lesyk/RUBBER/blob/master/RUBBER/RUBBER_Demo.gif)

####Configurations
Set next vars to fetch datas:
```
private let GOOGLE_KEY = ""
private let UBER_KEY = ""
private let CLIENT_ID = ""
```
