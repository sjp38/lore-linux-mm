Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 421A46B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 15:39:24 -0500 (EST)
Date: Thu, 19 Feb 2009 20:36:48 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/7] slab: introduce kzfree()
In-Reply-To: <499DB6EC.3020904@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0902192022210.8254@blonde.anvils>
References: <499BE7F8.80901@csr.com>  <1234954488.24030.46.camel@penberg-laptop>
  <20090219101336.9556.A69D9226@jp.fujitsu.com>  <1235034817.29813.6.camel@penberg-laptop>
  <Pine.LNX.4.64.0902191616250.8594@blonde.anvils> <1235066556.3166.26.camel@calx>
 <Pine.LNX.4.64.0902191819060.28475@blonde.anvils> <499DB6EC.3020904@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Vrabel <david.vrabel@csr.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Feb 2009, Pekka Enberg wrote:
> Hugh Dickins wrote:
> > 
> > But I fail to see it as a justification for kzfree(const void *):
> > if someone has "const char *string = kmalloc(size)" and then
> > wants that string zeroed before it is freed, then I think it's
> > quite right to cast out the const when calling kzfree().
> 
> Quite frankly, I fail to see how kzfree() is fundamentally different from
> kfree(). I don't see kzfree() as a memset() + kfree() but rather as a kfree()
> "and make sure no one sees my data". So the zeroing happens _after_ you've
> invalidated the pointer with kzfree() so there's no "zeroing of buffer going
> on".

Well, that would be one way of picturing it, yes.
Imagine the "z" as for "zap" rather than "zero",
and the mechanism as opaque as Hannes suggests.

> So the way I see it, Linus' argument for having const for kfree() applies
> to kzfree().
> 
> That said, if you guys think it's a merge blocker, by all means remove the
> const. I just want few less open-coded ksize() users, that's all.

I wouldn't call it a merge blocker, no; though I still
think it makes far more sense without the "const" there.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
