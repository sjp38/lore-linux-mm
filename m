Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id C5E5A6B0071
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 17:34:45 -0400 (EDT)
Received: by igbqq3 with SMTP id qq3so24816273igb.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:34:45 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id b3si4633532icl.84.2015.06.25.14.34.45
        for <linux-mm@kvack.org>;
        Thu, 25 Jun 2015 14:34:45 -0700 (PDT)
Date: Thu, 25 Jun 2015 16:34:43 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
	before basic setup
Message-ID: <20150625213443.GA129272@asylum.americas.sgi.com>
References: <20150513163157.GR2462@suse.de> <1431597783.26797.1@cpanel21.proisp.no> <20150624225028.GA97166@asylum.americas.sgi.com> <20150625204855.GC26927@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150625204855.GC26927@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

On Thu, Jun 25, 2015 at 09:48:55PM +0100, Mel Gorman wrote:
> On Wed, Jun 24, 2015 at 05:50:28PM -0500, Nathan Zimmer wrote:
> > My apologies for taking so long to get back to this.
> > 
> > I think I did locate two potential sources of slowdown.
> > One is the set_cpus_allowed_ptr as I have noted previously.
> > However I only notice that on the very largest boxes.
> > I did cobble together a patch that seems to help.
> > 
> 
> If you are using kthread_create_on_node(), is it even necessary to call
> set_cpus_allowed_ptr() at all?
> 

Yup kthread_create_on_node unconditionanly calls
set_cpus_allowed_ptr(task, cpu_all_mask);
It does it to avoid inherting kthreadd's properties.

Not being familiar with scheduling code I assumed I missed something.
However it sounds like it should respect the choice.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
