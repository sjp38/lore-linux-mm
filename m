Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1DDAE6B00D7
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 20:15:48 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D0FjFA013352
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Oct 2010 09:15:46 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 56B8B45DE52
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 09:15:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E17C045DE56
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 09:15:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C72D7E08001
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 09:15:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 323AC1DB803C
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 09:15:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: RFC: Implement hwpoison on free for soft offlining
In-Reply-To: <20101012131414.GC20436@basil.fritz.box>
References: <20101012181439.ADA9.A69D9226@jp.fujitsu.com> <20101012131414.GC20436@basil.fritz.box>
Message-Id: <20101013091553.ADB1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Oct 2010 09:15:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> > To me, it's no problem if this keep 64bit only. IOW, I only dislike to
> > add 32bit page flags.
> > 
> > Yeah, memory corruption is very crap and i think your effort has a lot
> > of worth :)
> 
> Thanks.
> 
> > 
> > 
> > offtopic, I don't think CONFIG_MEMORY_FAILURE and CONFIG_HWPOISON_ON_FREE
> > are symmetric nor easy understandable. can you please consider naming change?
> > (example, CONFIG_HWPOISON/CONFIG_HWPOISON_ON_FREE, 
> > CONFIG_MEMORY_FAILURE/CONFIG_MEMORY_FAILURE_SOFT_OFFLINE)
> 
> memory-failure was the old name before hwpoison as a term was invented
> by Andrew.
> 
> In theory it would make sense to rename everything to "hwpoison" now.
> But I decided so far the disadvantages from breaking user configurations
> and the impact from renaming files far outweight the small benefits
> in clarity.
> 
> So right now I prefer to keep the status quo, but name everything
> new hwpoison.

ok. I've got it. thanks :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
