Received: from root by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 1BXIKj-0001Yn-00
	for <linux-mm@kvack.org>; Mon, 07 Jun 2004 13:30:29 +0200
Received: from 61.16.153.178 ([61.16.153.178])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 07 Jun 2004 13:30:29 +0200
Received: from linux by 61.16.153.178 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 07 Jun 2004 13:30:29 +0200
From: Nirendra Awasthi <linux@nirendra.net>
Subject: Determining if process is having core dump
Date: Mon, 07 Jun 2004 15:51:38 +0530
Message-ID: <ca1fk9$92t$3@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
	Is there a way for a unrelated process to determine if another process 
is exiting and is in the state of having core dump.

		In solaris, this can be determined using libkvm(checking process flags 
for SDOCORE and COREDUMP). Is there a way to do this in linux 2.6

	One of the things I observed is flag in /proc/<pid>/stat (9th 
attribute) is set to non-zero after process receives a signal to quit 
after core dump (SIGABRT, SIGQUIT etc.). Is it an indication that 
process is going to exit or what does it indicates.
	
	Is there some other way to determine this. I don't want to limit size 
of core file to 0 using ulimit, as this file is required to be analyzed 
later.
	Also, while process is exiting and it receives another signal, it is 
corrupting the core dump.

-Nirendra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
