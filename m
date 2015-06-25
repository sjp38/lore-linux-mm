Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 95ECA6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 16:57:49 -0400 (EDT)
Received: by wiga1 with SMTP id a1so889052wig.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:57:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fh9si10680328wib.20.2015.06.25.13.57.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 13:57:48 -0700 (PDT)
Date: Thu, 25 Jun 2015 21:57:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-ID: <20150625205744.GE26927@suse.de>
References: <20150513163157.GR2462@suse.de>
 <1431597783.26797.1@cpanel21.proisp.no>
 <20150624225028.GA97166@asylum.americas.sgi.com>
 <20150625204855.GC26927@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150625204855.GC26927@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

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

That aside, are you aware of any failure with this series as it currently
stands in Andrew's tree that this patch is meant to address?  It seems
like a nice follow-on that would boot faster on very large machines but
if it's addressing a regression then it's very important as the series
cannot be merged with known critical failures.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
