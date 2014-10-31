Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id E850C280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 12:58:43 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id x12so7030488wgg.18
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 09:58:43 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ee10si15355961wib.21.2014.10.31.09.58.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Oct 2014 09:58:42 -0700 (PDT)
Date: Fri, 31 Oct 2014 17:58:36 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/5] mm: gup: add __get_user_pages_unlocked to customize
 gup_flags
Message-ID: <20141031165836.GW23531@worktop.programming.kicks-ass.net>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
 <1414600520-7664-3-git-send-email-aarcange@redhat.com>
 <20141030121737.GB31134@node.dhcp.inet.fi>
 <20141030174309.GL19606@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141030174309.GL19606@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Thu, Oct 30, 2014 at 06:43:09PM +0100, Andrea Arcangeli wrote:
> On Thu, Oct 30, 2014 at 02:17:37PM +0200, Kirill A. Shutemov wrote:
> > On Wed, Oct 29, 2014 at 05:35:17PM +0100, Andrea Arcangeli wrote:
> > > diff --git a/mm/gup.c b/mm/gup.c
> > > index a8521f1..01534ff 100644
> > > --- a/mm/gup.c
> > > +++ b/mm/gup.c
> > > @@ -591,9 +591,9 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
> > >  						int write, int force,
> > >  						struct page **pages,
> > >  						struct vm_area_struct **vmas,
> > > -						int *locked, bool notify_drop)
> > > +						int *locked, bool notify_drop,
> > > +						unsigned int flags)
> > 
> > Argument list getting too long. Should we consider packing them into a
> > struct?
> 
> It's __always_inline, so it's certainly not a runtime concern. The
> whole point of using __always_inline is to optimize away certain
> branches at build time.

Its also exported:

+EXPORT_SYMBOL(__get_user_pages_unlocked);

Note that __always_inline is only valid within the same translation unit
(unless you get LTO working).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
