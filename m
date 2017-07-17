Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 852EF6B02FD
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 19:32:09 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v76so2133626qka.5
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 16:32:09 -0700 (PDT)
Received: from mail-qk0-x231.google.com (mail-qk0-x231.google.com. [2607:f8b0:400d:c09::231])
        by mx.google.com with ESMTPS id z188si520476qke.98.2017.07.17.16.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 16:32:08 -0700 (PDT)
Received: by mail-qk0-x231.google.com with SMTP id t2so921712qkc.1
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 16:32:08 -0700 (PDT)
Date: Mon, 17 Jul 2017 19:32:05 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 10/10] percpu: add optimizations on allocation path for
 the bitmap allocator
Message-ID: <20170717233205.GD585283@devbig577.frc2.facebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-11-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716022315.19892-11-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Sat, Jul 15, 2017 at 10:23:15PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> This patch adds two optimizations to the allocation path. The first is
> to not consider a chunk if the requested allocation cannot fit in the
> chunk's contig_hint. The benefit is that this avoids unncessary scanning
> over a chunk as the assumption is memory pressure is high and creating a
> new chunk has minimal consequences. This may fail when the contig_hint
> has poor alignment, but again we fall back on the high memory pressure
> argument.
> 
> The second is just a fail-fast mechanism. When allocating, a offset is
> identified within a block and then scanning is used to see if it will
> fit. An offset should never be returned unless it is known to fit, so
> here we just bind the scanning to the size of a block.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Looks good to me and there's nothing wrong with these two
optimizations being in a separate patch but they might be too little
to help reviewing / debugging in any noticeable way.  It'd be great if
more significant parts can be separated out.  If not, this is fine
too.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
