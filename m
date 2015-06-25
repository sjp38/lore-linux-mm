Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD8A6B0075
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 17:37:45 -0400 (EDT)
Received: by iebrt9 with SMTP id rt9so63649488ieb.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:37:45 -0700 (PDT)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id k7si26294783icw.34.2015.06.25.14.37.44
        for <linux-mm@kvack.org>;
        Thu, 25 Jun 2015 14:37:44 -0700 (PDT)
Date: Thu, 25 Jun 2015 16:37:43 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
	before basic setup
Message-ID: <20150625213743.GB129272@asylum.americas.sgi.com>
References: <20150513163157.GR2462@suse.de> <1431597783.26797.1@cpanel21.proisp.no> <20150624225028.GA97166@asylum.americas.sgi.com> <20150625204855.GC26927@suse.de> <20150625205744.GE26927@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150625205744.GE26927@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

On Thu, Jun 25, 2015 at 09:57:44PM +0100, Mel Gorman wrote:
> On Thu, Jun 25, 2015 at 09:48:55PM +0100, Mel Gorman wrote:
> > On Wed, Jun 24, 2015 at 05:50:28PM -0500, Nathan Zimmer wrote:
> > > My apologies for taking so long to get back to this.
> > > 
> > > I think I did locate two potential sources of slowdown.
> > > One is the set_cpus_allowed_ptr as I have noted previously.
> > > However I only notice that on the very largest boxes.
> > > I did cobble together a patch that seems to help.
> > > 
> > 
> > If you are using kthread_create_on_node(), is it even necessary to call
> > set_cpus_allowed_ptr() at all?
> > 
> 
> That aside, are you aware of any failure with this series as it currently
> stands in Andrew's tree that this patch is meant to address?  It seems
> like a nice follow-on that would boot faster on very large machines but
> if it's addressing a regression then it's very important as the series
> cannot be merged with known critical failures.
> 

Nope I haven't recorded any failures without it.
I just get concerned when I see some scaling issues that something COULD go wrong.


Nate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
