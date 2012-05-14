Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id D9EDE6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 18:34:57 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so4609006wgb.26
        for <linux-mm@kvack.org>; Mon, 14 May 2012 15:34:56 -0700 (PDT)
Subject: Re: [PATCH v2] mm: Fix slab->page _count corruption.
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1337034597-1826-1-git-send-email-pshelar@nicira.com>
References: <1337034597-1826-1-git-send-email-pshelar@nicira.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 May 2012 00:34:52 +0200
Message-ID: <1337034892.8512.652.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pravin B Shelar <pshelar@nicira.com>
Cc: cl@linux.com, penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Mon, 2012-05-14 at 15:29 -0700, Pravin B Shelar wrote:
> On arches that do not support this_cpu_cmpxchg_double slab_lock is used
> to do atomic cmpxchg() on double word which contains page->_count.
> page count can be changed from get_page() or put_page() without taking
> slab_lock. That corrupts page counter.
> 
> Following patch fixes it by moving page->_count out of cmpxchg_double
> data. So that slub does no change it while updating slub meta-data in
> struct page.

I say again : Page is owned by slub, so get_page() or put_page() is not
allowed ?

How is put_page() going to work with order-1 or order-2 allocations ?

Me very confused by these Nicira patches.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
