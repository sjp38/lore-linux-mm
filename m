Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m656pUQ0028577
	for <linux-mm@kvack.org>; Sat, 5 Jul 2008 16:51:30 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m656q2hl3395780
	for <linux-mm@kvack.org>; Sat, 5 Jul 2008 16:52:02 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m656qSvn014943
	for <linux-mm@kvack.org>; Sat, 5 Jul 2008 16:52:28 +1000
Message-ID: <486F1A29.4020407@linux.vnet.ibm.com>
Date: Sat, 05 Jul 2008 12:22:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm 0/5] swapcgroup (v3)
References: <20080704151536.e5384231.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080704151536.e5384231.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> Hi.
> 
> This is new version of swapcgroup.
> 
> Major changes from previous version
> - Rebased on 2.6.26-rc5-mm3.
>   The new -mm has been released, but these patches
>   can be applied on 2.6.26-rc8-mm1 too with only some offset warnings.
>   I tested these patches on 2.6.26-rc5-mm3 with some fixes about memory,
>   and it seems to work fine.
> - (NEW) Implemented force_empty.
>   Currently, it simply uncharges all the charges from the group.
> 
> Patches
> - [1/5] add cgroup files
> - [2/5] add a member to swap_info_struct
> - [3/5] implement charge and uncharge
> - [4/5] modify vm_swap_full() 
> - [5/5] implement force_empty
> 
> ToDo(in my thought. Feel free to add some others here.)
> - need some documentation
>   Add to memory.txt? or create a new documentation file?
> 

I think memory.txt is good. But then, we'll need to add a Table of Contents to
it, so that swap controller documentation can be located easily.

> - add option to disable only this feature
>   I'm wondering if this option is needed.
>   memcg has already the boot option to disable it.
>   Is there any case where memory should be accounted but swap should not?
> 

That depends on what use case you are trying to provide. Let's say I needed
backward compatibility with 2.6.25, then I would account for memory and leave
out swap (even though we have swap controller).

> - hierarchy support
> - move charges along with task
>   Both of them need more discussion.
> 

Yes, they do.

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
