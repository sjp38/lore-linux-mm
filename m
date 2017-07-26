Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21A926B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 17:42:55 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id j124so70174772qke.6
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:42:55 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id q24si8973708qkl.177.2017.07.26.14.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 14:42:54 -0700 (PDT)
Received: by mail-qk0-x232.google.com with SMTP id x191so26971011qka.5
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:42:54 -0700 (PDT)
Date: Wed, 26 Jul 2017 17:42:45 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 23/23] percpu: update header to contain bitmap
 allocator explanation.
Message-ID: <20170726214245.GD742618@devbig577.frc2.facebook.com>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-24-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-24-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:20PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The other patches contain a lot of information, so adding this
> information in a separate patch. It adds my copyright and a brief
> explanation of how the bitmap allocator works. There is a minor typo as
> well in the prior explanation so that is fixed.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Applied 14-23 to percpu/for-4.14.

Great work, thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
