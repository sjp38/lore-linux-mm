Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 35B3D6B008A
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 05:54:52 -0500 (EST)
Subject: Re: [patch 1/7] slab: introduce kzfree()
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <499BE7F8.80901@csr.com>
References: <20090217182615.897042724@cmpxchg.org>
	 <20090217184135.747921027@cmpxchg.org>  <499BE7F8.80901@csr.com>
Date: Wed, 18 Feb 2009 12:54:48 +0200
Message-Id: <1234954488.24030.46.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Vrabel <david.vrabel@csr.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-02-18 at 10:50 +0000, David Vrabel wrote:
> Johannes Weiner wrote:
> > +void kzfree(const void *p)
> 
> Shouldn't this be void * since it writes to the memory?

No. kfree() writes to the memory as well to update freelists, poisoning
and such so kzfree() is not at all different from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
