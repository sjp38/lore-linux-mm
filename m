Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27F386B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:24:41 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c56so341841wrc.5
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 04:24:41 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 1si2043469edw.116.2018.04.17.04.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 04:24:39 -0700 (PDT)
Date: Tue, 17 Apr 2018 12:24:13 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180417112412.GB28901@castle.DHCP.thefacebook.com>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
 <20180413135923.GT17484@dhcp22.suse.cz>
 <13f1f5b5-f3f8-956c-145a-4641fb996048@suse.cz>
 <20180413142821.GW17484@dhcp22.suse.cz>
 <20180413143716.GA5378@cmpxchg.org>
 <20180416114144.GK17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180416114144.GK17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Apr 16, 2018 at 01:41:44PM +0200, Michal Hocko wrote:
> On Fri 13-04-18 10:37:16, Johannes Weiner wrote:
> > On Fri, Apr 13, 2018 at 04:28:21PM +0200, Michal Hocko wrote:
> > > On Fri 13-04-18 16:20:00, Vlastimil Babka wrote:
> > > > We would need kmalloc-reclaimable-X variants. It could be worth it,
> > > > especially if we find more similar usages. I suspect they would be more
> > > > useful than the existing dma-kmalloc-X :)
> > > 
> > > I am still not sure why __GFP_RECLAIMABLE cannot be made work as
> > > expected and account slab pages as SLAB_RECLAIMABLE
> > 
> > Can you outline how this would work without separate caches?
> 
> I thought that the cache would only maintain two sets of slab pages
> depending on the allocation reuquests. I am pretty sure there will be
> other details to iron out and maybe it will turn out that such a large
> portion of the chache would need to duplicate the state that a
> completely new cache would be more reasonable. Is this worth exploring
> at least? I mean something like this should help with the fragmentation
> already AFAIU. Accounting would be just free on top.

IMO, this approach is much better than duplicating all kmalloc caches.
It's definitely has to be explored and discussed.

Thank you!
