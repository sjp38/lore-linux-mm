Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF4746B1A30
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 13:19:44 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id f126-v6so846659ywh.4
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 10:19:44 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 190-v6si1858898ybh.656.2018.08.20.10.19.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 10:19:43 -0700 (PDT)
Date: Mon, 20 Aug 2018 10:19:01 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH RFC] mm: don't miss the last page because of round-off
 error
Message-ID: <20180820171855.GA3993@tower.DHCP.thefacebook.com>
References: <20180817231834.15959-1-guro@fb.com>
 <20180818012213.GA14115@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180818012213.GA14115@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Fri, Aug 17, 2018 at 06:22:13PM -0700, Matthew Wilcox wrote:
> On Fri, Aug 17, 2018 at 04:18:34PM -0700, Roman Gushchin wrote:
> > -			scan = div64_u64(scan * fraction[file],
> > -					 denominator);
> > +			if (scan > 1)
> > +				scan = div64_u64(scan * fraction[file],
> > +						 denominator);
> 
> Wouldn't we be better off doing a div_round_up?  ie:
> 
> 	scan = div64_u64(scan * fraction[file] + denominator - 1, denominator);
> 
> although i'd rather hide that in a new macro in math64.h than opencode it
> here.

Good idea! Will do in v2.

Thanks!
