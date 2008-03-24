Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2OCOprR026995
	for <linux-mm@kvack.org>; Mon, 24 Mar 2008 17:54:51 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2OCOp3J1224840
	for <linux-mm@kvack.org>; Mon, 24 Mar 2008 17:54:51 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2OCOpDr028685
	for <linux-mm@kvack.org>; Mon, 24 Mar 2008 12:24:51 GMT
Message-ID: <47E79CF0.6040308@linux.vnet.ibm.com>
Date: Mon, 24 Mar 2008 17:52:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] another swap controller for cgroup
References: <20080317020407.8512E1E7995@siro.lan> <47DE2894.6010306@mxp.nes.nec.co.jp> <47E79A26.3070401@mxp.nes.nec.co.jp>
In-Reply-To: <47E79A26.3070401@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: yamamoto@valinux.co.jp, minoura@valinux.co.jp, Linux MM <linux-mm@kvack.org>, Linux Containers <containers@lists.osdl.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> Daisuke Nishimura wrote:
>> Hi, Yamamoto-san.
>>
>> I'm reviewing and testing your patch now.
>>
> 
> In building kernel infinitely(in a cgroup of
> memory.limit=64M and swap.limit=128M, with swappiness=100),
> almost all of the swap (1GB) is consumed as swap cache
> after a day or so.
> As a result, processes are occasionally OOM-killed even when
> the swap.usage of the group doesn't exceed the limit.
> 
> I don't know why the swap cache uses up swap space.
> I will test whether a similar issue happens without your patch.
> Do you have any thoughts?
> 
> 
> BTW, I think that it would be better, in the sence of
> isolating memory resource, if there is a framework
> to limit the usage of swap cache.

We had this earlier, but dropped it later due to issues related to swap
readahead and assigning the pages to the correct cgroup.

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
