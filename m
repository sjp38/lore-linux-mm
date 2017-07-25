Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2B4A6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:32:16 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q1so77002416qkb.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:32:16 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id i43si11509115qtc.237.2017.07.25.12.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:32:16 -0700 (PDT)
Received: by mail-qk0-x234.google.com with SMTP id d145so68174744qkc.2
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:32:16 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:32:14 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 19/23] percpu: update alloc path to only scan if
 contig hints are broken
Message-ID: <20170725193213.GS18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-20-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-20-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:16PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> Metadata is kept per block to keep track of where the contig hints are.
> Scanning can be avoided when the contig hints are not broken. In that
> case, left and right contigs have to be managed manually.
> 
> This patch changes the allocation path hint updating to only scan when
> contig hints are broken.
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
