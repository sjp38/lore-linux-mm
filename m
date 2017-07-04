Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 227B46B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 06:53:52 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v60so45174630wrc.7
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 03:53:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k186si20367249wmg.36.2017.07.04.03.53.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 03:53:45 -0700 (PDT)
Date: Tue, 4 Jul 2017 12:53:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: "mm: use early_pfn_to_nid in page_ext_init" broken on some
 configurations?
Message-ID: <20170704105342.GJ14722@dhcp22.suse.cz>
References: <20170630141847.GN22917@dhcp22.suse.cz>
 <54336b9a-6dc7-890f-1900-c4188fb6cf1a@suse.cz>
 <bfec3bba-8e15-8156-9ae2-01b1c6319a16@suse.cz>
 <20170704052304.GC28589@js1304-desktop>
 <45268b53-88dc-4129-725c-df5849e494db@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45268b53-88dc-4129-725c-df5849e494db@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Yang Shi <yang.shi@linaro.org>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 04-07-17 11:39:57, Vlastimil Babka wrote:
> On 07/04/2017 07:23 AM, Joonsoo Kim wrote:
> > On Mon, Jul 03, 2017 at 04:18:01PM +0200, Vlastimil Babka wrote:
> >> allocated" looks much more sane there. But there's a warning nevertheless.
> > 
> > Warning would comes from the fact that drain_all_pages() is called
> > before mm_percpu_wq is initialised. We could remove WARN_ON_ONCE() and add
> > drain_local_page(zone) to fix the problem.
> 
> Wouldn't that still leave some period during boot where kernel already
> runs on multiple CPU's, but mm_percpu_wq is not yet initialized and
> somebody tries to use it? We want to catch such cases, right?

I haven't checked the boot sequence but if we know that we need
mm_percpu_wq initialized earlier than moving it should be not a big deal
I guess.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
