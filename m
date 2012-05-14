Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 94B9B6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 14:53:30 -0400 (EDT)
Date: Mon, 14 May 2012 13:53:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: Fix slab->page flags corruption.
In-Reply-To: <1337020877-20087-1-git-send-email-pshelar@nicira.com>
Message-ID: <alpine.DEB.2.00.1205141352440.26304@router.home>
References: <1337020877-20087-1-git-send-email-pshelar@nicira.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pravin B Shelar <pshelar@nicira.com>
Cc: penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Mon, 14 May 2012, Pravin B Shelar wrote:

> Transparent huge pages can change page->flags (PG_compound_lock)
> without taking Slab lock. Since THP can not break slab pages we can
> safely access compound page without taking compound lock.
>
> Specificly this patch fixes race between compound_unlock and slab
> functions which does page-flags update. This can occur when
> get_page/put_page is called on page from slab object.

You need to also get this revbiewed by the THP folks like Andrea &
friends.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
