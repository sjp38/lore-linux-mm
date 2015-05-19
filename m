Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 03F946B00DC
	for <linux-mm@kvack.org>; Tue, 19 May 2015 15:06:39 -0400 (EDT)
Received: by wgfl8 with SMTP id l8so28731958wgf.2
        for <linux-mm@kvack.org>; Tue, 19 May 2015 12:06:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m6si3289206wjb.7.2015.05.19.12.06.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 12:06:37 -0700 (PDT)
Date: Tue, 19 May 2015 20:06:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-ID: <20150519190632.GL2462@suse.de>
References: <20150513163157.GR2462@suse.de>
 <1431597783.26797.1@cpanel21.proisp.no>
 <555B8180.1020100@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <555B8180.1020100@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nzimmer <nzimmer@sgi.com>
Cc: Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

On Tue, May 19, 2015 at 01:31:28PM -0500, nzimmer wrote:
> After double checking the patches it seems everything is ok.
> 
> I had to rerun quite a bit since the machine was reconfigured and I
> wanted to be thorough.
> My latest timings are quite close to my previous reported numbers.
> 
> The hang issue I encountered turned out to be unrelated to these
> patches so that is a separate bundle of fun.
> 

Ok, sorry to hear about the hanging but I'm glad to hear the patches are
not responsible. Thanks for testing and getting back.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
