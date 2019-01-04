Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C403E8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 04:46:11 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so34692855edb.22
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 01:46:11 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id a15si1192938edc.169.2019.01.04.01.46.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 01:46:10 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 0B5B81C171A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 09:46:10 +0000 (GMT)
Date: Fri, 4 Jan 2019 09:46:08 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: Do not wake kswapd with zone lock held
Message-ID: <20190104094608.GK31517@techsingularity.net>
References: <20190103225712.GJ31517@techsingularity.net>
 <51d17b9f-5c5b-5964-0943-668b679964cd@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51d17b9f-5c5b-5964-0943-668b679964cd@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Qian Cai <cai@lca.pw>, Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>

On Fri, Jan 04, 2019 at 09:18:38AM +0100, Vlastimil Babka wrote:
> On 1/3/19 11:57 PM, Mel Gorman wrote:
> > While zone->flag could have continued to be unused, there is potential
> > for moving some existing fields into the flags field instead. Particularly
> > read-mostly ones like zone->initialized and zone->contiguous.
> > 
> > Reported-by: syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com
> > Tested-by: Qian Cai <cai@lca.pw>
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an
> external fragmentation event occurs")
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

Thanks

-- 
Mel Gorman
SUSE Labs
