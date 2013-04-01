Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id D968E6B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 15:14:43 -0400 (EDT)
Received: by mail-ea0-f175.google.com with SMTP id r16so1140992ead.34
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 12:14:42 -0700 (PDT)
Message-ID: <5159DCA0.3080408@gmail.com>
Date: Mon, 01 Apr 2013 21:14:40 +0200
From: Ivan Danov <huhavel@gmail.com>
MIME-Version: 1.0
Subject: System freezes when RAM is full (64-bit)
Content-Type: multipart/alternative;
 boundary="------------050604090202000102030103"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: 1162073@bugs.launchpad.net

This is a multi-part message in MIME format.
--------------050604090202000102030103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The system freezes when RAM gets completely full. By using MATLAB, I can 
get all 8GB RAM of my laptop full and it immediately freezes, needing 
restart using the hardware button. Other people have reported the bug at 
since 2007. It seems that only the 64-bit version is affected and people 
have reported that enabling DMA in BIOS settings solve the problem. 
However, my laptop lacks such an option in the BIOS settings, so I am 
unable to test it. More information about the bug could be found at: 
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1162073 and 
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/159356.

Best Regards,
Ivan


--------------050604090202000102030103
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>

    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    The system freezes when RAM gets completely full. By using MATLAB, I
    can get all 8GB RAM of my laptop full and it immediately freezes,
    needing restart using the hardware button. Other people have
    reported the bug at since 2007. It seems that only the 64-bit
    version is affected and people have reported that enabling DMA in
    BIOS settings solve the problem. However, my laptop lacks such an
    option in the BIOS settings, so I am unable to test it. More
    information about the bug could be found at:
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    <a
      href="https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1162073">https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1162073</a>
    and
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    <a
      href="https://bugs.launchpad.net/ubuntu/+source/linux/+bug/159356">https://bugs.launchpad.net/ubuntu/+source/linux/+bug/159356</a>.<br>
    <br>
    Best Regards,<br>
    Ivan<br>
    <br>
  </body>
</html>

--------------050604090202000102030103--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
