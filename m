Date: Fri, 23 Aug 2002 11:28:48 +0500 (GMT+0500)
From: Anil Kumar <anilk@cdotd.ernet.in>
Subject: ramfs/tmpfs/shmfs  doubt  
Message-ID: <Pine.OSF.4.10.10208231100500.4550-100000@moon.cdotd.ernet.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello All,

   I have  a   doubt regarding use Of ramfs .In which cases should i
use ramfs/shmfs/tmpfs/ramdisk and how page cache is used in these cases?

   On my board i have 8 MB RAM and a Flash (to store Kernal and
Application code and persistent Application Data). Also i have no additional 
device to use it as a swap.So if for swap i have to use a part of
RAM(Compressed Swap suggested on this mailing list earlier).

   I am planning to create a file system at boot time in RAM and download
application binaries to that and run.RAM is limited so my  requirement is 
that i do not want to have two copies of data in the RAM (One in File
System i create and other one in Page Cache ).

  What is the best available mechanism i should follow?
   (Can  i use ramfs/tmpfs to solve the above problem?)

  Can i run a linux kernel disabling swapping (In my case no
 additional device for swap is available) ?

 Thanks a lot,  
 Anil


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
