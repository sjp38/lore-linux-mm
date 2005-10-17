Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9HHTZI2021126
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 13:29:35 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9HHVkTB525674
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 11:31:46 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9HHUsRO004160
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 11:30:54 -0600
Received: from dyn9047017102.beaverton.ibm.com (dyn9047017102.beaverton.ibm.com [9.47.17.102])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j9HHUrPC004116
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 11:30:53 -0600
Subject: [RFC] OVERCOMMIT_ALWAYS extension
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Mon, 17 Oct 2005 10:30:19 -0700
Message-Id: <1129570219.23632.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi MM-experts,

I have been looking at possible ways to extend OVERCOMMIT_ALWAYS
to avoid its abuse.

Few of the applications (database) would like to overcommit
memory (by creating shared memory segments more than RAM+swap),
but use only portion of it at any given time and get rid
of portions of them through madvise(DONTNEED), when needed. 
They want this, especially to handle hotplug memory situations 
(where apps may not have clear idea on how much memory they have 
in the system at the time of shared memory create). Currently, 
they are using OVERCOMMIT_ALWAYS system wide to do this - but 
they are affecting every other application on the system.

I am wondering, if there is a better way to do this. Simple solution
would be to add IPC_OVERCOMMIT flag or add CAP_SYS_ADMIN to
do the overcommit. This way only specific applications, requesting
this would be able to overcommit. I am worried about, the over
all affects it has on the system. But again, this can't be worse
than system wide  OVERCOMMIT_ALWAYS. Isn't it ?

Ideas ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
