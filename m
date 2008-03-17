Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2H5EEGO026315
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:14:14 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2H5DKUb3674134
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:13:20 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2H5DQtH032221
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:13:26 +1100
Message-ID: <47DDFD97.6000209@linux.vnet.ibm.com>
Date: Mon, 17 Mar 2008 10:41:51 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] another swap controller for cgroup
References: <20080317020407.8512E1E7995@siro.lan>
In-Reply-To: <20080317020407.8512E1E7995@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: containers@lists.osdl.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, minoura@valinux.co.jp
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
> hi,
> 
> the following is another swap controller, which was designed and
> implemented independently from nishimura-san's one.
> 
> some random differences from nishimura-san's one:
> - counts and limits the number of ptes with swap entries instead of
>   on-disk swap slots.
> - no swapon-time memory allocation.
> - anonymous objects (shmem) are not accounted.
> - precise wrt moving tasks between cgroups. 
> 
> this patch contains some unrelated small fixes which i've posted separately:
> - exe_file fput botch fix
> - cgroup_rmdir EBUSY fix
> 
> any comments?
> 

Hi, YAMAMOTO-San,

Thanks for the patch. I'll review and test it. I'll get back soon

Balbir

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
