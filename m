Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EA2CB6B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 14:50:03 -0500 (EST)
Message-ID: <499DB6EC.3020904@cs.helsinki.fi>
Date: Thu, 19 Feb 2009 21:45:48 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 1/7] slab: introduce kzfree()
References: <499BE7F8.80901@csr.com>  <1234954488.24030.46.camel@penberg-laptop>  <20090219101336.9556.A69D9226@jp.fujitsu.com>  <1235034817.29813.6.camel@penberg-laptop>  <Pine.LNX.4.64.0902191616250.8594@blonde.anvils> <1235066556.3166.26.camel@calx> <Pine.LNX.4.64.0902191819060.28475@blonde.anvils>
In-Reply-To: <Pine.LNX.4.64.0902191819060.28475@blonde.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Vrabel <david.vrabel@csr.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Hugh.

Hugh Dickins wrote:
> Thanks for that, I remember it now.
> 
> Okay, that's some justification for kfree(const void *).
> 
> But I fail to see it as a justification for kzfree(const void *):
> if someone has "const char *string = kmalloc(size)" and then
> wants that string zeroed before it is freed, then I think it's
> quite right to cast out the const when calling kzfree().

Quite frankly, I fail to see how kzfree() is fundamentally different 
from kfree(). I don't see kzfree() as a memset() + kfree() but rather as 
a kfree() "and make sure no one sees my data". So the zeroing happens 
_after_ you've invalidated the pointer with kzfree() so there's no 
"zeroing of buffer going on". So the way I see it, Linus' argument for 
having const for kfree() applies to kzfree().

That said, if you guys think it's a merge blocker, by all means remove 
the const. I just want few less open-coded ksize() users, that's all.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
