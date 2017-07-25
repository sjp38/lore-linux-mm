Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 813EB6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:38:35 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l55so83267333qtl.7
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:38:35 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id d26si7552450qtb.292.2017.07.25.12.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:38:34 -0700 (PDT)
Received: by mail-qk0-x233.google.com with SMTP id u139so13058717qka.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:38:34 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:38:33 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 20/23] percpu: update free path to take advantage of
 contig hints
Message-ID: <20170725193832.GT18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-21-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-21-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:17PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The bitmap allocator must keep metadata consistent. The easiest way is
> to scan after every allocation for each affected block and the entire
> chunk. This is rather expensive.
> 
> The free path can take advantage of current contig hints to prevent
> scanning within the start and end block.  If a scan is needed, it can
> be done by scanning backwards from the start and forwards from the end
> to identify the entire free area this can be combined with. The blocks
> can then be updated by some basic checks rather than complete block
> scans.
> 
> A chunk scan happens when the freed area makes a page free, a block
> free, or spans across blocks. This is necessary as the contig hint at
> this point could span across blocks. The check uses the minimum of page
> size and the block size to allow for variable sized blocks. There is a
> tradeoff here with not updating after every free. It is possible a
> contig hint in one block can be merged with the contig hint in the next
> block. This means the contig hint can be off by up to a page. However,
> if the chunk's contig hint is contained in one block, the contig hint
> will be accurate.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
