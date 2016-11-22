Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FEF66B0253
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:48:24 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id d187so29379904ywe.1
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:48:24 -0800 (PST)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id m123si6493311yba.274.2016.11.22.08.48.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 08:48:23 -0800 (PST)
Received: by mail-yw0-x243.google.com with SMTP id r204so2639790ywb.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:48:23 -0800 (PST)
Date: Tue, 22 Nov 2016 11:48:22 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort
 allocations in blkcg
Message-ID: <20161122164822.GA5459@htj.duckdns.org>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161121230332.GA3767@htj.duckdns.org>
 <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

Hello,

On Tue, Nov 22, 2016 at 04:47:49PM +0100, Vlastimil Babka wrote:
> Thanks. Makes me wonder whether we should e.g. add __GFP_NOWARN to
> GFP_NOWAIT globally at some point.

Yeah, that makes sense.  The caller is explicitly saying that it's
okay to fail the allocation.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
