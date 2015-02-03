Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B14846B0073
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 10:21:25 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id k14so45184566wgh.8
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 07:21:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cp9si29207936wib.81.2015.02.03.07.21.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 07:21:23 -0800 (PST)
Date: Tue, 3 Feb 2015 16:21:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
Message-ID: <20150203152121.GC8914@dhcp22.suse.cz>
References: <20150202165525.GM2395@suse.de>
 <54CFF8AC.6010102@intel.com>
 <54D08483.40209@suse.cz>
 <20150203111600.GR2395@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150203111600.GR2395@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, mtk.manpages@gmail.com, linux-man@vger.kernel.org

On Tue 03-02-15 11:16:00, Mel Gorman wrote:
> On Tue, Feb 03, 2015 at 09:19:15AM +0100, Vlastimil Babka wrote:
[...]
> > And if we agree that there is indeed no guarantee, what's the actual semantic
> > difference from MADV_FREE? I guess none? So there's only a possible perfomance
> > difference?
> > 
> 
> Timing. MADV_DONTNEED if it has an effect is immediate, is a heavier
> operations and RSS is reduced. MADV_FREE only has an impact in the future
> if there is memory pressure.

JFTR. the man page for MADV_FREE has been proposed already
(https://lkml.org/lkml/2014/12/5/63 should be the last version AFAIR). I
do not see it in the man-pages git tree but the patch was not in time
for 3.19 so I guess it will only appear in 3.20.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
