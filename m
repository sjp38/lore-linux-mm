Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 250646B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 12:14:33 -0400 (EDT)
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <linux-mm@kvack.org>; Tue, 08 Sep 2009 09:14:37 -0700
Date: Tue, 8 Sep 2009 09:14:32 -0700
From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH v3 0/5] kmemleak: few small cleanups and clear command
 support
Message-ID: <20090908161432.GA8839@mosca>
References: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
 <1252344570.23780.110.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1252344570.23780.110.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Luis Rodriguez <Luis.Rodriguez@Atheros.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "penberg@cs.helsinki.fi" <penberg@cs.helsinki.fi>, "mcgrof@gmail.com" <mcgrof@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 07, 2009 at 10:29:30AM -0700, Catalin Marinas wrote:
> On Fri, 2009-09-04 at 17:44 -0700, Luis R. Rodriguez wrote:
> > Here is my third respin, this time rebased ontop of:
> >
> > git://linux-arm.org/linux-2.6 kmemleak
> >
> > As suggested by Catalin we now clear the list by only painting reported
> > unreferenced objects and the color we use is grey to ensure future
> > scans are possible on these same objects to account for new allocations
> > in the future referenced on the cleared objects.
> >
> > Patch 3 is now a little different, now with a paint_ptr() and
> > a __paint_it() helper.
> 
> Thanks for the patches. They look ok now, I'll merge them tomorrow to my
> kmemleak branch and give them a try.
> 
> > I tested this by clearing kmemleak after bootup, then writing my
> > own buggy module which kmalloc()'d onto some internal pointer,
> > scanned, unloaded, and scanned again and then saw a new shiny
> > report come up:
> 
> BTW, kmemleak comes with a test module which does this.

Thanks for the note, I'll use this in case I need to test more stuff.

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
