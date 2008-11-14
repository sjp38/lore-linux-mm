Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAEBcqxi028188
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 22:38:52 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAEBXMi2207458
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 22:33:23 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAEBXMRt026493
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 22:33:22 +1100
Message-ID: <491D61FA.3050704@linux.vnet.ibm.com>
Date: Fri, 14 Nov 2008 17:03:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] memcg updates (14/Nov/2008)
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, pbadari@us.ibm.com, jblunck@suse.de, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Several patches are posted after last update (12/Nov),
> it's better to catch all up as series.
> 
> All patchs are mm-of-the-moment snapshot 2008-11-13-17-22
>   http://userweb.kernel.org/~akpm/mmotm/
> (You may need to patch fs/dquota.c and fix kernel/auditsc.c CONFIG error)
> 
> New ones are 1,2,3 and 9. 
> 
> IMHO, patch 1-4 are ready to go. (but I want Ack from Balbir to 3/9)

Hi, Kamezawa,

Sorry to keep you waiting, I've been spending time on memcg hierarchy patches
(testing, fixing, revisiting them). Hopefully, I'll find some time quickly.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
