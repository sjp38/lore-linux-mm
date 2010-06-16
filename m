Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ED2686B01AC
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 14:54:34 -0400 (EDT)
Subject: Re: [RFC PATCH] mm: let the bdi_writeout fraction respond more
 quickly
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1276526681.1980.89.camel@castor.rsk>
References: <1276523894.1980.85.camel@castor.rsk>
	 <1276526681.1980.89.camel@castor.rsk>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 16 Jun 2010 20:54:26 +0200
Message-ID: <1276714466.1745.625.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 15:44 +0100, Richard Kennedy wrote:
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 2fdda90..315dd04 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -144,7 +144,7 @@ static int calc_period_shift(void)
> >       else
> >               dirty_total =3D (vm_dirty_ratio * determine_dirtyable_mem=
ory()) /
> >                               100;
> > -     return 2 + ilog2(dirty_total - 1);
> > +     return ilog2(dirty_total - 1) - 4;
> >  }=20

IIRC I suggested similar things in the past and all we needed to do was
find people doing the measurements on different bits of hardware or so..

I don't have any problems with the approach, all we need to make sure is
that we never return 0 or a negative number (possibly ensure a minimum
positive shift value).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
