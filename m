Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m454OHLI016313
	for <linux-mm@kvack.org>; Mon, 5 May 2008 14:24:17 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m454Ou6g4685882
	for <linux-mm@kvack.org>; Mon, 5 May 2008 14:24:56 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m454P4in008857
	for <linux-mm@kvack.org>; Mon, 5 May 2008 14:25:04 +1000
Message-ID: <481E8BFA.1000903@linux.vnet.ibm.com>
Date: Mon, 05 May 2008 09:54:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 0/4] Add rlimit controller to cgroups (v3)
References: <23630056.1209914669637.kamezawa.hiroyu@jp.fujitsu.com> <20080503213726.3140.68845.sendpatchset@localhost.localdomain> <28343987.1209914862098.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28343987.1209914862098.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

kamezawa.hiroyu@jp.fujitsu.com wrote:
>>   "+This controller framework is designed to be extensible to control any
>>   "+resource limit (memory related) with little effort."
>>   memory only ? Ok, all you want to do is related to memory, but someone
>>   may want to limit RLIMIT_CPU by group or RLIMIT_CORE by group or....
>>   (I have no plan but they seems useful.;)
> ...RLIMIT_MEMLOCK is in my want-to-do-list ;)
> 

Mine too, but I want to get to it after the hierarchy and soft limit patches.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
