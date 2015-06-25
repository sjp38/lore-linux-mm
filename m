Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id D96516B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 16:49:00 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so72470437wgq.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:49:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pd7si54726149wjb.51.2015.06.25.13.48.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 13:48:59 -0700 (PDT)
Date: Thu, 25 Jun 2015 21:48:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-ID: <20150625204855.GC26927@suse.de>
References: <20150513163157.GR2462@suse.de>
 <1431597783.26797.1@cpanel21.proisp.no>
 <20150624225028.GA97166@asylum.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150624225028.GA97166@asylum.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

On Wed, Jun 24, 2015 at 05:50:28PM -0500, Nathan Zimmer wrote:
> My apologies for taking so long to get back to this.
> 
> I think I did locate two potential sources of slowdown.
> One is the set_cpus_allowed_ptr as I have noted previously.
> However I only notice that on the very largest boxes.
> I did cobble together a patch that seems to help.
> 

If you are using kthread_create_on_node(), is it even necessary to call
set_cpus_allowed_ptr() at all?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
