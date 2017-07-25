Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53D5B6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:25:10 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k2so75936737qkf.10
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:25:10 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id t39si4224666qtb.353.2017.07.25.11.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:25:09 -0700 (PDT)
Received: by mail-qk0-x233.google.com with SMTP id k2so35406339qkf.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:25:09 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:25:08 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 09/23] percpu: combine percpu address checks
Message-ID: <20170725182508.GI18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-10-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-10-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:06PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The percpu address checks for the reserved and dynamic region chunks are
> now specific to each region. The address checking logic can be combined
> taking advantage of the global references to the dynamic and static
> region chunks.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Reviewed-by: Josef Bacik <jbacik@fb.com>

Tho this probably would have been fine to do in the previous patch.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
