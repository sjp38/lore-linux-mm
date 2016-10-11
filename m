Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9FA06B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 17:36:52 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id tz10so23903472pab.3
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:36:52 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id to9si4831990pab.33.2016.10.11.14.36.51
        for <linux-mm@kvack.org>;
        Tue, 11 Oct 2016 14:36:52 -0700 (PDT)
Date: Wed, 12 Oct 2016 08:36:48 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] z3fold: add shrinker
Message-ID: <20161011213648.GC27872@dastard>
References: <20161011231408.2728c93ad89acb517fc6c9f0@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011231408.2728c93ad89acb517fc6c9f0@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Oct 11, 2016 at 11:14:08PM +0200, Vitaly Wool wrote:
> This patch implements shrinker for z3fold. This shrinker
> implementation does not free up any pages directly but it allows
> for a denser placement of compressed objects which results in
> less actual pages consumed and higher compression ratio therefore.
> 
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

This seems to implement the shrinker API we removed a ~3 years ago
(commit a0b02131c5fc ("shrinker: Kill old ->shrink API.")). Forward
porting and testing required, perhaps?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
