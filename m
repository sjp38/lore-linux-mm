Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B43A56B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:49:21 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i19so43927974qte.5
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:49:21 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id k67si11261172qte.213.2017.07.25.12.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:49:21 -0700 (PDT)
Received: by mail-qk0-x233.google.com with SMTP id u139so13220795qka.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:49:20 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:49:19 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 23/23] percpu: update header to contain bitmap
 allocator explanation.
Message-ID: <20170725194919.GW18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-24-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-24-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:20PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The other patches contain a lot of information, so adding this
> information in a separate patch. It adds my copyright and a brief
> explanation of how the bitmap allocator works. There is a minor typo as
> well in the prior explanation so that is fixed.
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
