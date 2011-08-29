Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 25486900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 10:20:56 -0400 (EDT)
Date: Mon, 29 Aug 2011 09:20:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2]slub: add a type for slab partial list position
In-Reply-To: <1314587187.4523.55.camel@debian>
Message-ID: <alpine.DEB.2.00.1108290904130.16005@router.home>
References: <1314059823.29510.19.camel@sli10-conroe>  <alpine.DEB.2.00.1108231023470.21267@router.home>  <1314147472.29510.25.camel@sli10-conroe> <1314587187.4523.55.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "Li, Shaohua" <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, "Chen, Tim C" <tim.c.chen@intel.com>

On Mon, 29 Aug 2011, Alex,Shi wrote:

> On Wed, 2011-08-24 at 08:57 +0800, Li, Shaohua wrote:
> > On Tue, 2011-08-23 at 23:25 +0800, Christoph Lameter wrote:
> > > On Tue, 23 Aug 2011, Shaohua Li wrote:
> > >
> > > > Adding slab to partial list head/tail is sensentive to performance.
> > > > So adding a type to document it to avoid we get it wrong.
> > >
> > > I think that if you want to make it more descriptive then using the stats
> > > values (DEACTIVATE_TO_TAIL/HEAD) would avoid having to introduce an
> > > additional enum and it would also avoid the if statement in the stat call.
> > ok, that's better.
> >
> > Subject: slub: explicitly document position of inserting slab to partial list
> >
> > Adding slab to partial list head/tail is sensitive to performance.
> > So explicitly uses DEACTIVATE_TO_TAIL/DEACTIVATE_TO_HEAD to document
> > it to avoid we get it wrong.
>
> Frankly speaking, using DEACTIVATE_TO_TAIL/DEACTIVATE_TO_HEAD in
> slab_alloc, slab_free make code hard to understand. Just adding some
> comments will be more clear and understandable. like the following:
> Do you think so?

Yes, I like that more.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
