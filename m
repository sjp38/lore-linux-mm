Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id EAB696B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:04:04 -0400 (EDT)
Date: Tue, 15 May 2012 09:04:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: Fix slab->page _count corruption.
In-Reply-To: <1337034892.8512.652.camel@edumazet-glaptop>
Message-ID: <alpine.DEB.2.00.1205150903320.6488@router.home>
References: <1337034597-1826-1-git-send-email-pshelar@nicira.com> <1337034892.8512.652.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Tue, 15 May 2012, Eric Dumazet wrote:

> > Following patch fixes it by moving page->_count out of cmpxchg_double
> > data. So that slub does no change it while updating slub meta-data in
> > struct page.
>
> I say again : Page is owned by slub, so get_page() or put_page() is not
> allowed ?

It is allowed since slab memory can be used for DMA.

> How is put_page() going to work with order-1 or order-2 allocations ?

It is always incrementing the page count of the head page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
