Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAD3DlF0030026
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 14:13:47 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAD3FF0v4624468
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 14:15:17 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAD3F5Ux013267
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 14:15:05 +1100
Message-ID: <491B9BB3.6010701@linux.vnet.ibm.com>
Date: Thu, 13 Nov 2008 08:44:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/6] memcg: free all at rmdir
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com> <20081112122656.c6e56248.kamezawa.hiroyu@jp.fujitsu.com> <20081112160758.3dca0b22.akpm@linux-foundation.org> <20081113114908.42a6a8a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081113114908.42a6a8a7.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 12 Nov 2008 16:07:58 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
>> If we do this then we can make the above "keep" behaviour non-optional,
>> and the operator gets to choose whether or not to drop the caches
>> before doing the rmdir.
>>
>> Plus, we get a new per-memcg drop_caches capability.  And it's a nicer
>> interface, and it doesn't have the obvious races which on_rmdir has,
>> etc.
>>
>> hm?
>>
> 
> Balbir, how would you want to do ?
> 
> I planned to post shrink_uage patch later (it's easy to be implemented) regardless
> of acceptance of this patch.
> 
> So, I think we should add shrink_usage now and drop this is a way to go.

I am a bit concerned about dropping stuff at will later. Ubuntu 8.10 has memory
controller enabled and we exposed memory.force_empty interface there and now
we've dropped it (bad on our part). I think we should have deprecated it and
dropped it later.

> I think I can prepare patch soon. But I'd like to push handle-swap-cache patch
> before introducing shrink_usage. 
> 
> Then, posting following 2 patch for this week is my current intention.
>  [1/2] handle swap cache
>  [2/2] shrink_usage patch (instead of this patch)
> 
> Objection ?

No.. just be wary of breaking API, please!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
