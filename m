Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0546D6B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 15:10:19 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o3so76768699qto.15
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:10:18 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id p22si7506qtg.225.2017.07.17.12.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 12:10:16 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id j25so5625770qtf.0
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:10:16 -0700 (PDT)
Date: Mon, 17 Jul 2017 15:10:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 07/10] percpu: fix misnomer in schunk/dchunk variable
 names
Message-ID: <20170717191009.GA585283@devbig577.frc2.facebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-8-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716022315.19892-8-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Sat, Jul 15, 2017 at 10:23:12PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> With moving the base_addr in the chunks responsible for serving the
> first chunk up, the use of schunk/dchunk in pcpu_setup_first_chunk no
> longer makes sense. This makes the linking in the first chunk code not
> rely on a ternary and renames the variables to a shared variable, chunk,
> because the allocation path is sequential.

Ah cool, please disregard my previous comment on the misnomer.  You
can explain in the previous patch's description that a follow-up patch
will resolve the situation tho.

> @@ -1709,13 +1709,13 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
>  		INIT_LIST_HEAD(&pcpu_slot[i]);
>  
>  	/*
> +	 * Initialize first chunk.
> +	 * pcpu_first_chunk will always manage the dynamic region of the
> +	 * first chunk.  The static region is dropped as those addresses

Would "not covered by any chunk" be clearer than "dropped"?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
