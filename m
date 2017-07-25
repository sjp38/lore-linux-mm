Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 99E156B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:40:29 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l22so37608573qtf.9
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:40:29 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id w7si1061777qte.364.2017.07.25.12.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:40:29 -0700 (PDT)
Received: by mail-qk0-x233.google.com with SMTP id d136so78836475qkg.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:40:29 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:40:27 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 21/23] percpu: use metadata blocks to update the chunk
 contig hint
Message-ID: <20170725194026.GU18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-22-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-22-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:18PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The largest free region will either be a block level contig hint or an
> aggregate over the left_free and right_free areas of blocks. This is a
> much smaller set of free areas that need to be checked than a full
> traverse.
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
