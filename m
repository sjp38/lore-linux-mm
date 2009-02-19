Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0859D6B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 04:13:40 -0500 (EST)
Subject: Re: [patch 1/7] slab: introduce kzfree()
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090219101336.9556.A69D9226@jp.fujitsu.com>
References: <499BE7F8.80901@csr.com>
	 <1234954488.24030.46.camel@penberg-laptop>
	 <20090219101336.9556.A69D9226@jp.fujitsu.com>
Date: Thu, 19 Feb 2009 11:13:37 +0200
Message-Id: <1235034817.29813.6.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Vrabel <david.vrabel@csr.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-02-18 at 10:50 +0000, David Vrabel wrote:
> > > Johannes Weiner wrote:
> > > > +void kzfree(const void *p)
> > > 
> > > Shouldn't this be void * since it writes to the memory?
> > 
> > No. kfree() writes to the memory as well to update freelists, poisoning
> > and such so kzfree() is not at all different from it.

On Thu, 2009-02-19 at 10:22 +0900, KOSAKI Motohiro wrote:
> I don't think so. It's debetable thing.
> 
> poisonig is transparent feature from caller.
> but the caller of kzfree() know to fill memory and it should know.

Debatable, sure, but doesn't seem like a big enough reason to make
kzfree() differ from kfree().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
