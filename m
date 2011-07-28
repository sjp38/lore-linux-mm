Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AA1A66B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 02:58:23 -0400 (EDT)
Date: Thu, 28 Jul 2011 12:28:18 +0530 (IST)
From: Prateek Sharma <prateeks@cse.iitb.ac.in>
Subject: What does drop_caches do?
Message-ID: <alpine.DEB.2.00.1107281215550.14640@nsl-11>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kernelnewbies@kernelnewbies.org

Hello everyone,
 	I've been trying to understand the role of the pagecache, starting with 
drop_caches and observing what it does.
 	From my understanding of the code (fs/drop_caches.c) , it walks over all 
the open files/inodes, and invalidates all the mapped pages. Pages which are 
*not* dropped are either dirty,in-use,anonymous,mapped(to pagetable),or 
writeback) . Is my understanding correct?
 	But, when i run drop_caches, there are still some pages which show up as 
cached. Why arent all cache pages getting dropped ?
 	My confusion runs much deeper. What exactly constitutes the pagecache? 
All filebacked pages ? mmaped files ? If i copy a bunch of files, why does my 
cache get polluted with those pages?

Thanks for reading. I'd be grateful if someone can enlighten me about some 
pagecache internals .

(Please keep me CC'ed)

<begin experiment>
root@tripitz:/etc/apt# free -m
              total       used       free     shared    buffers     cached
Mem:          1995       1854        140          0         79        700
-/+ buffers/cache:       1074        920
Swap:         4767        762       4005
root@tripitz:/etc/apt# echo 3 > /proc/sys/vm/drop_caches
root@tripitz:/etc/apt# free -m
              total       used       free     shared    buffers     cached
Mem:          1995       1373        621          0          0        363
-/+ buffers/cache:       1009        985
Swap:         4767        762       4005

<end experiment>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
