Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 764F06B02F3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:22:00 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o4so27091878qta.8
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:22:00 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id m36si1300624qta.186.2017.07.25.12.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:22:00 -0700 (PDT)
Received: by mail-qk0-x236.google.com with SMTP id k2so36272109qkf.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:22:00 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:21:58 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 16/23] percpu: add first_bit to keep track of the
 first free in the bitmap
Message-ID: <20170725192157.GP18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-17-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-17-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:13PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> This patch adds first_bit to keep track of the first free bit in the
> bitmap. This hint helps prevent scanning of fully allocated blocks.
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
