Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2A3829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:44:03 -0400 (EDT)
Received: by wgfl8 with SMTP id l8so28846535wgf.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:44:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l17si93047wiv.77.2015.05.22.14.44.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 May 2015 14:44:01 -0700 (PDT)
Message-ID: <1432331020.2185.8.camel@stgolabs.net>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 22 May 2015 14:43:40 -0700
In-Reply-To: <555F6404.4010905@hp.com>
References: <1431597783.26797.1@cpanel21.proisp.no>
	 <1432276201.11133.1@cpanel21.proisp.no> <20150522093313.GZ2462@suse.de>
	 <555F6404.4010905@hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Mel Gorman <mgorman@suse.de>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, nzimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

On Fri, 2015-05-22 at 13:14 -0400, Waiman Long wrote:
> I think the non-temporal patch benefits mainly AMD systems. I have tried 
> the patch on both DragonHawk and it actually made it boot up a little 
> bit slower. I think the Intel optimized "rep stosb" instruction (used in 
> memset) is performing well. I had done similar test on zero page code 
> and the performance gain was non-conclusive.

fwiw I did some experiments with similar conclusions a while ago
(inconclusive with intel hw, maybe it was even the same machine ;)
Now, this was for optimizing clear_hugepage by using movnti, but I never
got to run it on an AMD box.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
