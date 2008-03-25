Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id m2P6cLYE103208
	for <linux-mm@kvack.org>; Tue, 25 Mar 2008 17:38:22 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2P6VDRK335996
	for <linux-mm@kvack.org>; Tue, 25 Mar 2008 17:31:13 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2P6VCQc026013
	for <linux-mm@kvack.org>; Tue, 25 Mar 2008 17:31:13 +1100
Message-ID: <47E89B80.3000806@linux.vnet.ibm.com>
Date: Tue, 25 Mar 2008 11:58:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious EBUSY on memory cgroup removal
References: <20080325054713.948EF1E92EC@siro.lan> <20080324225309.0a1ab8ec.akpm@linux-foundation.org> <20080325153020.d9179428.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080325153020.d9179428.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, containers@lists.osdl.org, linux-mm@kvack.org, minoura@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 24 Mar 2008 22:53:09 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> On Tue, 25 Mar 2008 14:47:13 +0900 (JST) yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
>>
>>> [ resending with To: akpm.  Andrew, can you include this in -mm tree? ]
>> Shouldn't it be in 2.6.25?
>>
> I think this should be.
> 
> Thanks,
> -Kame

Me too

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
