Received: from majestic ([192.168.12.245])
	by cyber.java.dezcom.mephi.edu (8.12.3/8.12.3/Debian -4) with ESMTP id gAKCBSE6031282
	for <linux-mm@kvack.org>; Wed, 20 Nov 2002 15:11:38 +0300
From: "Alexander Sbitnev" <shuras@dezcom.mephi.ru>
Subject: Different page cache polices for different devices?
Date: Wed, 20 Nov 2002 15:21:34 +0300
Message-ID: <000301c2908f$61566450$f50ca8c0@majestic>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
	I am searching for a way to tune page cache separately for
different disk storage.
Our problem is that we have file server and application server at the
one server box. Thus there
are continuous reads of files that placed on the file server disk
arrays. Effectiveness of page cache 
in this case is not big because we have a big amount of files and
absolutely uniform access to 
this files. 
 And there are a some seldom used files on the applications partitions.
This files can be effectively 
cached only if there is a way to keep them in the memory instead of
recently read fileserver areas. 

Is there the way of tuning Linux page cache to accept pages from the
separate device with higher/lower 
priority over pages from all other devices? Is there any solutions to
it?

Regards,
Shuras


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
