Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m7JAaCd8018824
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 16:06:12 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7JAaC2u1310758
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 16:06:12 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m7JAaBZ6013950
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 16:06:11 +0530
Message-ID: <48AAA217.8040307@linux.vnet.ibm.com>
Date: Tue, 19 Aug 2008 16:06:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm_owner: fix cgroup null dereference
References: <1218745013-9537-1-git-send-email-jirislaby@gmail.com> <48A49C78.7070100@linux.vnet.ibm.com> <48A9E82E.3060009@gmail.com> <48AA4003.5080300@linux.vnet.ibm.com> <48AA970D.5050403@gmail.com>
In-Reply-To: <48AA970D.5050403@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jiri Slaby wrote:
> On 08/19/2008 05:37 AM, Balbir Singh wrote:
>> Could you please help me with the steps to reproduce the problem.  I don't seem
>> to be hitting the mm->owner changed callback. I did have a test case for it when
>> I developed mm->owner functionality, but it does not trigger an oops for me.
> 
> I have no idea. My config is at:
> http://decibel.fi.muni.cz/~xslaby/config-memrlimit-oops
> I don't play with cgroups or anything, I just work on the system. Do you need a
> test case, it's obvious from the code as far as I can see?

Yes, the problem is obvious, but I usually use small test cases or test
scenarios to verify that the problem is fixed.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
