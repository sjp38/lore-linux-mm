Received: from list by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 1BY3JN-0004z3-00
	for <linux-mm@kvack.org>; Wed, 09 Jun 2004 15:40:13 +0200
Received: from 61.16.153.178 ([61.16.153.178])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 09 Jun 2004 15:40:13 +0200
Received: from linux by 61.16.153.178 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 09 Jun 2004 15:40:13 +0200
From: Nirendra Awasthi <linux@nirendra.net>
Subject: Reading struct_task in user space
Date: Wed, 09 Jun 2004 19:09:42 +0530
Message-ID: <ca73vo$vv8$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

  How can I read struct_task (defined in linux/sched.h) in user space, 
in order to determine if PF_DUMPCORE flag is set for the process and it 
is having core dump.

-Nirendra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
