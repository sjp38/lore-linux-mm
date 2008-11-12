Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAC3x2V8031532
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 14:59:02 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAC40Wxi3416104
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:00:35 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAC40Nrc022856
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:00:24 +1100
Message-ID: <491A54D5.4030006@linux.vnet.ibm.com>
Date: Wed, 12 Nov 2008 09:30:21 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/6] memcg updates (12/Nov/2008)
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Weekly updates on my queue.
> 
> Changes from previous (05/Nov)
>  - added "free all at rmdir" patch.
>  - fixed several bugs reported by Nishimura (Thanks!)
>  - many style bugs are fixed.
> 
> Brief description:
> [1/6].. free all at rmdir (and add attribute to memcg.)
> [2/6].. handle swap cache
> [3/6].. mem+swap controller kconfig
> [4/6].. swap_cgroup
> [5/6].. mem+swap controller
> [6/6].. synchrinized LRU (unify lru lock.)
> 
> I think it's near to a month to test this mem+swap controller internally.
> It's getting better. Making progress in step by step works good.
> 
> I'll send [1/6] and [2/6] to Andrew, tomorrow or weekend.(please do final check).
> 
> If no acks to [1/6] (I haven't got any ;), I'll postpone it and reschedule as [7/6].

Sorry, I have not looked at the patches yet, I am busy with the hierarchy
patches and number extraction.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
