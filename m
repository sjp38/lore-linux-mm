Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B71086B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 15:26:09 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n43so77017723qtc.13
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:26:09 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id v62si54914qkc.104.2017.07.17.12.26.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 12:26:08 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id q66so21831147qki.1
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:26:08 -0700 (PDT)
Date: Mon, 17 Jul 2017 15:26:02 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 08/10] percpu: change the number of pages marked in the
 first_chunk bitmaps
Message-ID: <20170717192602.GB585283@devbig577.frc2.facebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-9-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716022315.19892-9-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

Hello,

On Sat, Jul 15, 2017 at 10:23:13PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> This patch changes the allocator to only mark allocated pages for the
> region the population bitmap is used for. Prior, the bitmap was marked
> completely used as the first chunk was allocated and immutable. This is
> misleading because the first chunk may not be completely filled.
> Additionally, with moving the base_addr up in the previous patch, the
> population map no longer corresponds to what is being checked.

This in isolation makes sense although the rationale isn't clear from
the description.  Is it a mere cleanup or is this needed to enable
further changes?

> pcpu_nr_empty_pop_pages is used to ensure there are a handful of free
> pages around to serve atomic allocations. A new field, nr_empty_pop_pages,
> is added to the pcpu_chunk struct to keep track of the number of empty
> pages. This field is needed as the number of empty populated pages is
> globally kept track of and deltas are used to update it. This new field
> is exposed in percpu_stats.

But I can't see why this is being added or why this is in the same
patch with the previous change.

> Now that chunk->nr_pages is the number of pages the chunk is serving, it
> is nice to use this in the work function for population and freeing of
> chunks rather than use the global variable pcpu_unit_pages.

The same goes for the above part.  It's fine to collect misc changes
into a patch when they're trivial and related in some ways but the
content of this patch seems a bit random.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
