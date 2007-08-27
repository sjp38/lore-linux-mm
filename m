Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7RAdMGP032117
	for <linux-mm@kvack.org>; Mon, 27 Aug 2007 20:39:22 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7RAdLuA3604620
	for <linux-mm@kvack.org>; Mon, 27 Aug 2007 20:39:21 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7RAdKOP024213
	for <linux-mm@kvack.org>; Mon, 27 Aug 2007 20:39:21 +1000
Message-ID: <46D2A9D3.50703@linux.vnet.ibm.com>
Date: Mon, 27 Aug 2007 16:09:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH 5/10] Memory controller task migration (v7)
References: <20070824152043.16582.37727.sendpatchset@balbir-laptop> <20070827082635.195471BFA2C@siro.lan>
In-Reply-To: <20070827082635.195471BFA2C@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: akpm@linux-foundation.org, npiggin@suse.de, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> Allow tasks to migrate from one container to the other. We migrate
>> mm_struct's mem_container only when the thread group id migrates.
> 
>> +	/*
>> +	 * Only thread group leaders are allowed to migrate, the mm_struct is
>> +	 * in effect owned by the leader
>> +	 */
>> +	if (p->tgid != p->pid)
>> +		goto out;
> 
> does it mean that you can't move a process between containers
> once its thread group leader exited?
> 
> YAMAMOTO Takashi


Hi,

Good catch! Currently, we treat the mm as owned by the thread group leader.
But this policy can be easily adapted to any other desired policy.
Would you like to see it change to something else?

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
