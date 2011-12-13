Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id B11516B0270
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 10:44:38 -0500 (EST)
Date: Tue, 13 Dec 2011 16:44:32 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/4] mm: bootmem: drop superfluous range check when
 freeing pages in bulk
Message-ID: <20111213154432.GE1818@cmpxchg.org>
References: <1323784711-1937-1-git-send-email-hannes@cmpxchg.org>
 <1323784711-1937-4-git-send-email-hannes@cmpxchg.org>
 <20111213152843.GD4585@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20111213152843.GD4585@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 13, 2011 at 04:28:43PM +0100, Uwe Kleine-Konig wrote:
> Hello Johannes,
> 
> On Tue, Dec 13, 2011 at 02:58:30PM +0100, Johannes Weiner wrote:
> > The area node_bootmem_map represents is aligned to BITS_PER_LONG, and
> > all bits in any aligned word of that map valid.  When the represented
> > area extends beyond the end of the node, the non-existant pages will
> > be marked as reserved.
> > 
> > As a result, when freeing a page block, doing an explicit range check
> > for whether that block is within the node's range is redundant as the
> > bitmap is consulted anyway to see whether all pages in the block are
> > unreserved.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> I suggest to drop my patch then and add something like
> 
> 	Reported-by: $me
> 
> to this one instead.

Your patch is a real and obvious fix, while mine is just a cleanup but
has more obscure dependencies on how the bitmap is managed.

If you don't mind, I would prefer to keep them as separate changes.

> Other than that I will give your series a spin on my ARM machine later
> today.

Thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
