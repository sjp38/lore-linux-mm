Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C914C6B29A9
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:52:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k48-v6so2144374ede.14
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 03:52:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94-v6si197146ede.220.2018.08.23.03.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 03:52:54 -0700 (PDT)
Date: Thu, 23 Aug 2018 12:52:54 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180823105253.GB29735@dhcp22.suse.cz>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
 <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz>
 <20180822155250.GP13047@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822155250.GP13047@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed 22-08-18 11:52:50, Andrea Arcangeli wrote:
> On Wed, Aug 22, 2018 at 11:02:14AM +0200, Michal Hocko wrote:
[...]
> > I still have to digest the __GFP_THISNODE thing but I _think_ that the
> > alloc_pages_vma code is just trying to be overly clever and
> > __GFP_THISNODE is not a good fit for it. 
> 
> My option 2 did just that, it removed __GFP_THISNODE but only for
> MADV_HUGEPAGE and in general whenever reclaim was activated by
> __GFP_DIRECT_RECLAIM. That is also signal that the user really wants
> THP so then it's less bad to prefer THP over NUMA locality.
> 
> For the default which is tuned for short lived allocation, preferring
> local memory is most certainly better win for short lived allocation
> where THP can't help much, this is why I didn't remove __GFP_THISNODE
> from the default defrag policy.

Yes I agree.
-- 
Michal Hocko
SUSE Labs
