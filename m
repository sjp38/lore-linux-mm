Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 69AA66B0044
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 07:36:35 -0400 (EDT)
Received: by wgbds10 with SMTP id ds10so3879562wgb.26
        for <linux-mm@kvack.org>; Tue, 27 Mar 2012 04:36:33 -0700 (PDT)
Date: Tue, 27 Mar 2012 13:37:17 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH] mm: extend prefault helpers to fault in more than
 PAGE_SIZE
Message-ID: <20120327113717.GJ4276@phenom.ffwll.local>
References: <20120229153216.8c3ae31d.akpm@linux-foundation.org>
 <1330629779-1449-1-git-send-email-daniel.vetter@ffwll.ch>
 <20120301121557.0e0fd728.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120301121557.0e0fd728.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, Mar 01, 2012 at 12:15:57PM -0800, Andrew Morton wrote:
> On Thu,  1 Mar 2012 20:22:59 +0100
> Daniel Vetter <daniel.vetter@ffwll.ch> wrote:
> 
> > drm/i915 wants to read/write more than one page in its fastpath
> > and hence needs to prefault more than PAGE_SIZE bytes.
> > 
> > Add new functions in filemap.h to make that possible.
> > 
> > Also kill a copy&pasted spurious space in both functions while at it.
> > 
> >
> > ...
> >
> > +/* Multipage variants of the above prefault helpers, useful if more than
> > + * PAGE_SIZE of date needs to be prefaulted. These are separate from the above
> > + * functions (which only handle up to PAGE_SIZE) to avoid clobbering the
> > + * filemap.c hotpaths. */
> 
> Like this please:
> 
> /*
>  * Multipage variants of the above prefault helpers, useful if more than
>  * PAGE_SIZE of date needs to be prefaulted. These are separate from the above
>  * functions (which only handle up to PAGE_SIZE) to avoid clobbering the
>  * filemap.c hotpaths.
>  */
> 
> and s/date/data/

...

> Please merge it via the DRI tree.

Ok, I've queued this up 3.5 (it missed the 3.4 merge because a few of the
drm/i915 patches from that series haven't been reviewed in time) with the
comment fixed up and your Acked-by on the commit message. I hope the later
is ok, otherwise please yell.

Thanks for reviewing this.
-Daniel
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
