Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA9156B0069
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 09:53:37 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z190so72164042qkc.4
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 06:53:37 -0700 (PDT)
Received: from mail-qt0-f173.google.com (mail-qt0-f173.google.com. [209.85.216.173])
        by mx.google.com with ESMTPS id w46si9734625qta.144.2016.10.14.06.53.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 06:53:37 -0700 (PDT)
Received: by mail-qt0-f173.google.com with SMTP id m5so74846100qtb.3
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 06:53:37 -0700 (PDT)
Date: Fri, 14 Oct 2016 15:53:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: exclude isolated non-lru pages from
 NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Message-ID: <20161014135334.GF6063@dhcp22.suse.cz>
References: <1476340749-13281-1-git-send-email-ming.ling@spreadtrum.com>
 <20161013080936.GG21678@dhcp22.suse.cz>
 <20161014083219.GA20260@spreadtrum.com>
 <20161014113044.GB6063@dhcp22.suse.cz>
 <20161014134604.GA2179@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161014134604.GA2179@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ming Ling <ming.ling@spreadtrum.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

On Fri 14-10-16 22:46:04, Minchan Kim wrote:
[...]
> > > > Why don't you simply mimic what shrink_inactive_list does? Aka count the
> > > > number of isolated pages and then account them when appropriate?
> > > >
> > > I think i am correcting clearly wrong part. So, there is no need to
> > > describe it too detailed. It's a misunderstanding, and i will add
> > > more comments as you suggest.
> > 
> > OK, so could you explain why you prefer to relyon __PageMovable rather
> > than do a trivial counting during the isolation?
> 
> I don't get it. Could you elaborate it a bit more?

It is really simple. You can count the number of file and anonymous
pages while they are isolated and then account them to NR_ISOLATED_*
later. Basically the same thing we do during the reclaim. We absolutely
do not have to rely on __PageMovable and make this code more complex
than necessary.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
