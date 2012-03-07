Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 8D16E6B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 09:20:23 -0500 (EST)
Date: Wed, 7 Mar 2012 11:18:37 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH -v2] mm: SLAB Out-of-memory diagnostics
Message-ID: <20120307141836.GA2009@x61.redhat.com>
References: <20120305181041.GA9829@x61.redhat.com>
 <alpine.DEB.2.00.1203061941210.24600@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1203061941210.24600@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>

Howdy David,

On Tue, Mar 06, 2012 at 07:41:55PM -0800, David Rientjes wrote:
> > +		spin_lock_irqsave(&l3->list_lock, flags);
> 
> Could be spin_lock_irq(&l3->list_lock);

I don't think it would be safe making such assumption.

Note that spin_lock_irqsave() is used at slab_out_of_memory() because we cannot
guarantee that interrupts will be enabled/disabled by the time kmem_getpages()
is called in cache_grow() or fallback_alloc().

  Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
