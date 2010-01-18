Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 98B426B0082
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 15:41:45 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Mon, 18 Jan 2010 21:41:49 +0100
References: <1263549544.3112.10.camel@maxim-laptop> <201001171455.55909.rjw@sisk.pl> <201001181800.38574.oliver@neukum.org>
In-Reply-To: <201001181800.38574.oliver@neukum.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201001182141.49907.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Oliver Neukum <oliver@neukum.org>
Cc: Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Monday 18 January 2010, Oliver Neukum wrote:
> Am Sonntag, 17. Januar 2010 14:55:55 schrieb Rafael J. Wysocki:
> > +void mm_force_noio_allocations(void)
> > +{
> > +       /* Wait for all slowpath allocations using the old mask to complete */
> > +       down_write(&gfp_allowed_mask_sem);
> > +       saved_gfp_allowed_mask = gfp_allowed_mask;
> > +       gfp_allowed_mask &= ~(__GFP_IO | __GFP_FS);
> > +       up_write(&gfp_allowed_mask_sem);
> > +}
> 
> In addition to this you probably want to exhaust all memory reserves
> before you fail a memory allocation

I'm not really sure what you mean.

> and forbid the OOM killer to run.

The OOM killer has already been disabled at this point, by the freezer.

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
