Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: what is using memory?
Date: Sun, 10 Jun 2001 23:36:42 -0400
MIME-Version: 1.0
Message-Id: <01061023364200.03146@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have been trying to figure out what is using my memory

My box has 

320280K

>From boot I see

   924	kernel
  8224	reserved (initrd ramdisk?)
  1488	hash tables (dentry, inode, mount, buffer, page, tcp)

from lsmod I caculate
  
   876	for loaded modules
  
from proc/slabinfo

 11992	for all slabs

from proc/meminfo

 17140	buffer
123696	cache
 32303	free

leaving unaccounted

123627K 	

This is about 38% of my memory, and only about 46% is pageable
Is it possible to figure out what is using this?

This is with 2.4.6-pre2 with Rik's page_launder_improvements patch, 
lvm beta7 and some reieserfs patches applied, after about 12 hours
of uptime.

TIA,

Ed Tomlinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
