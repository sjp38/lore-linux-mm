Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D10726B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 00:38:31 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so7971236pdb.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 21:38:31 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id za2si17570556pbc.229.2015.03.30.21.38.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 21:38:30 -0700 (PDT)
Received: by pddn5 with SMTP id n5so7930640pdd.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 21:38:30 -0700 (PDT)
Date: Tue, 31 Mar 2015 13:38:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
Message-ID: <20150331043817.GA16825@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-4-git-send-email-minchan@kernel.org>
 <20150330052250.GA3008@blaptop>
 <20150330085112.GB10982@moon>
 <20150330085915.GC3008@blaptop>
 <20150330211446.GE18876@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150330211446.GE18876@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Mar 31, 2015 at 12:14:46AM +0300, Cyrill Gorcunov wrote:
> On Mon, Mar 30, 2015 at 05:59:15PM +0900, Minchan Kim wrote:
> > Hi Cyrill,
> > 
> > On Mon, Mar 30, 2015 at 11:51:12AM +0300, Cyrill Gorcunov wrote:
> > > On Mon, Mar 30, 2015 at 02:22:50PM +0900, Minchan Kim wrote:
> > > > 2nd description trial.
> > > ...
> > > Hi Minchan, could you please point for which repo this patch,
> > > linux-next?
> > 
> > It was based on v4.0-rc5-mmotm-2015-03-24-17-02.
> > As well, I confirmed it was applied on local-next-20150327.
> > 
> > Thanks.
> 
> Hi Minchan! I managed to fetch mmotm and the change looks
> reasonable to me. Still better to wait for review from Mel
> or Hugh, maybe I miss something obvious.

Thanks for the review!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
