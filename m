Received: from ds02c00.directory.ray.com (ds02c00.directory.ray.com [147.25.138.118])
	by dfw-gate2.raytheon.com (8.12.5/8.12.5) with ESMTP id g8DElpNa014442
	for <linux-mm@kvack.org>; Fri, 13 Sep 2002 09:47:52 -0500 (CDT)
Received: from ds02c00.directory.ray.com (root@localhost)
	by ds02c00.directory.ray.com (8.12.1/8.12.1) with ESMTP id g8DEljkR024674
	for <linux-mm@kvack.org>; Fri, 13 Sep 2002 09:47:50 -0500 (CDT)
Received: from rtshou-ds01.hou.us.ray.com ([192.27.45.147])
	by ds02c00.directory.ray.com (8.12.1/8.12.1) with ESMTP id g8DElZC9024572
	for <linux-mm@kvack.org>; Fri, 13 Sep 2002 09:47:35 -0500 (CDT)
MIME-Version: 1.0
From: Mark_H_Johnson@raytheon.com
Subject: Query on mlockall and reported RSS
Date: Fri, 13 Sep 2002 09:46:32 -0500
Message-ID: <OFBE4B072B.F17F9B97-ON86256C33.0051285A-86256C33.00512A7F@hou.us.ray.com>
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just curious, but if I have an application, run as root, that uses
 mlocall (MCL_CURRENT | MCL_FUTURE)
with no error status returned, we get output like the following in top...

 ...  SIZE   RSS    SHARE  ...
 ...  160M   84M    34256  ...

for our application. It seems odd to us that RSS and SIZE are not equal.
This is being seen on a kernel built from 2.4.16.

 - How can we truly be sure that all of our application is locked
into memory?
 - Could someone explain why the RSS is not equal to the size in
this case?

Thanks.
  --Mark Johnson


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
