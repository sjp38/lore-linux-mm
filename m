Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68E996B0292
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 04:55:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v88so44932381wrb.1
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 01:55:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n18si12886641wmi.169.2017.07.04.01.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jul 2017 01:55:39 -0700 (PDT)
Date: Tue, 4 Jul 2017 10:55:37 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH stable-only] mm: fix classzone_idx underflow in
 shrink_zones()
Message-ID: <20170704085537.GA20372@kroah.com>
References: <cf25f1a5-5276-90ea-1eac-f2a2aceffaef@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf25f1a5-5276-90ea-1eac-f2a2aceffaef@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: stable <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Tue, Jul 04, 2017 at 10:45:43AM +0200, Vlastimil Babka wrote:
> Hi,
> 
> I realize this is against the standard stable policy, but I see no other
> way, because the mainline accidental fix is part of 34+ patch reclaim
> rework, that would be absurd to try to backport into stable. The fix is
> a one-liner though.
> 
> The bug affects at least 4.4.y, and likely also older stable trees that
> backported commit 7bf52fb891b6, which itself was a fix for 3.19 commit
> 6b4f7799c6a5. You could revert the 7bf52fb891b6 backport, but then 32bit
> with highmem might suffer from OOM or thrashing.

I need a bunch of acks from developers in this area before I can take
this patch :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
