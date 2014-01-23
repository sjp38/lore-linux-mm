Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 044B06B0037
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 05:30:49 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id g10so6628800wiw.1
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 02:30:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i7si8769035wjz.160.2014.01.23.02.30.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 02:30:48 -0800 (PST)
Date: Thu, 23 Jan 2014 10:30:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Bug 67651] Bisected: Lots of fragmented mmaps cause gimp to
 fail in 3.12 after exceeding vm_max_map_count
Message-ID: <20140123103044.GE4963@suse.de>
References: <20140122190816.GB4963@suse.de>
 <20140122191928.GQ1574@moon>
 <20140122223325.GA30637@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140122223325.GA30637@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, gnome@rvzt.net, drawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Thu, Jan 23, 2014 at 02:33:25AM +0400, Cyrill Gorcunov wrote:
> On Wed, Jan 22, 2014 at 11:19:28PM +0400, Cyrill Gorcunov wrote:
> > > commit. Test case was simple -- try and open the large file described in
> > > the bug. I did not investigate the patch itself as I'm just reporting
> > > the results of the bisection. If I had to guess, I'd say that VMA
> > > merging has been affected.
> > 
> > Thanks a lot for report, Mel! I'm investigating...
> 
> Mel, here is a quick fix for bring merging back (just in case if you
> have a minute to test it and confirm the merging were affected). It
> seems I've lost setting up vma-softdirty bit somewhere and procedure
> which tests vma flags mathcing fails, will continue investigating/testing
> tomorrow.

The test case passes with this patch applied to 3.13 so that appears
to confirm that this is related to VM_SOFTDIRTY preventing merges.
Unfortunately I did not have slabinfo tracking enabled to double check
the number of vm_area_structs in teh system.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
