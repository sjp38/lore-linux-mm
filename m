Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAD2nmfi027048
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 11:49:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7522445DD79
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:49:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 53C1745DD78
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:49:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3788B1DB803A
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:49:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E5C7A1DB803B
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:49:44 +0900 (JST)
Date: Thu, 13 Nov 2008 11:49:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/6] memcg: free all at rmdir
Message-Id: <20081113114908.42a6a8a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112160758.3dca0b22.akpm@linux-foundation.org>
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112122656.c6e56248.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112160758.3dca0b22.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, menage@google.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 16:07:58 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:
> If we do this then we can make the above "keep" behaviour non-optional,
> and the operator gets to choose whether or not to drop the caches
> before doing the rmdir.
> 
> Plus, we get a new per-memcg drop_caches capability.  And it's a nicer
> interface, and it doesn't have the obvious races which on_rmdir has,
> etc.
> 
> hm?
> 

Balbir, how would you want to do ?

I planned to post shrink_uage patch later (it's easy to be implemented) regardless
of acceptance of this patch.

So, I think we should add shrink_usage now and drop this is a way to go.
I think I can prepare patch soon. But I'd like to push handle-swap-cache patch
before introducing shrink_usage. 

Then, posting following 2 patch for this week is my current intention.
 [1/2] handle swap cache
 [2/2] shrink_usage patch (instead of this patch)

Objection ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
