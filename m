Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 8A2996B005A
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 21:09:30 -0500 (EST)
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <alpine.DEB.2.00.1112021401200.13405@router.home>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
	 <1322825802.2607.10.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1112021401200.13405@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 05 Dec 2011 10:21:04 +0800
Message-ID: <1323051664.22361.358.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, 2011-12-03 at 04:02 +0800, Christoph Lameter wrote:
> On Fri, 2 Dec 2011, Eric Dumazet wrote:
> 
> > netperf (loopback or ethernet) is a known stress test for slub, and your
> > patch removes code that might hurt netperf, but benefit real workload.
> >
> > Have you tried instead this far less intrusive solution ?
> >
> > if (tail == DEACTIVATE_TO_TAIL ||
> >     page->inuse > page->objects / 4)
> >          list_add_tail(&page->lru, &n->partial);
> > else
> >          list_add(&page->lru, &n->partial);
> 
> One could also move this logic to reside outside of the call to
> add_partial(). This is called mostly from __slab_free() so the logic could
> be put in there.
I'm wondering where the improvement comes from. The new added partial
page almost always has few free objects (the inuse < objects/4 isn't
popular I thought), that's why we add it to list tail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
