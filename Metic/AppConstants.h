//
//  AppConstants.h
//  Metis
//
//  Created by mac on 14-5-20.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#ifndef Metis_AppConstants_h
#define Metis_AppConstants_h

#import "HttpSender.h"

HttpSender* httpSender;

enum Operation_Code
{
    REGISTER = 0,
    LOGIN = 1,
    GET_USER_INFO = 2,
    GET_MY_EVENTS = 3,
    GET_EVENTS = 4,
    ADD_FRIEND = 5,
    UPLOAD_PHONEBOOK = 6,
    SEARCH_FRIEND = 7,
    SYNCHRONIZE_FRIEND = 8,
    LAUNCH_EVENT = 9,
    PARTICIPATE_EVENT = 10,
    INVITE_FRIENDS =  11,
    SEARCH_EVENT = 12,
    GET_IMPORTANT_INFO = 13,
    ADD_COMMENT = 14,
    DELETE_COMMENT = 15,
    GET_COMMENTS = 16,
    ADD_GOOD = 17,
    CHANGE_SETTINGS = 18,
    CHANGE_PW = 19,
    ADD_PCOMMENT = 20,
    GET_PCOMMENTS = 21,
    DELETE_PCOMMENT = 22,
    GET_PHOTO_LIST = 23,
    GET_EVENT_PARTICIPANTS = 24,
    GET_AVATAR_UPDATETIME = 25,
    GET_VIDEO_LIST = 26,
    ADD_VCOMMENT = 27,
    GET_VCOMMENTS = 28,
    DELETE_VCOMMENT = 29,
    GET_EVENT_RECOMMEND = 30,
    GET_VERSION_INFO = 31,
    UPDATE_LOCATION =32,
    GET_NEARBY_FRIENDS = 33,
    KANKAN = 34,
    UPLOADPHOTO = 35,
    DELETEPHOTO = 36,
    
    
};

enum Return_Code
{
    NORMAL_REPLY =100,
    USER_NOT_FOUND,
    LOGIN_SUC = 102,
    PASSWD_NOT_CORRECT = 103,
    GET_SALT = 104,
    USER_EXIST = 105,
    SERVER_ERROR = 106,
    ALREADY_FRIENDS = 107,
    REQUEST_FAIL = 108,
    COMMENT_NOT_EXIST = 109,
    EVENT_NOT_EXIST = 110,
    ALREADY_IN_EVENT = 111,
    DATABASE_ERROR = 112,
    NO_AVATAR = 113,
    PHOTO_NOT_EXIST = 114,
    VIDEO_NOT_EXIST = 115,
    REQUEST_DATA_ERROR = 116,
    USER_ALREADY_ONLINE = 117,
    USER_LOGOUT_SUC = 118,
};

#endif
