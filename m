Received: from [192.168.1.190] ([192.168.1.190])
	by arianne.in.ishoni.com (8.11.6/Ishonir2) with ESMTP id gBLCxvt32265
	for <linux-mm@kvack.org>; Sat, 21 Dec 2002 18:29:59 +0530
Subject: copy_from_user
From: Amol Kumar Lad <amolk@ishoni.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 21 Dec 2002 18:26:30 -0500
Message-Id: <1040513191.2250.79.camel@amol.in.ishoni.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi,
  Suppose kernel tries to do copy_from_user from a pointer that does not
have any mapping. i.e. not in any VMA (and not in stack area too..). 
Now (for 1386)
access_ok --> __range_ok
Suppose the 'from' ptr is within range then how kernel is making sure
that 'from' is invalid ??
The page fault handler will see that 'from' has no mapping and it will
die.. 

Please help
Amol



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
