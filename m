Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3036B02F4
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:05:13 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p3so46653673qtg.4
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:05:13 -0700 (PDT)
Received: from mail-qt0-x232.google.com (mail-qt0-x232.google.com. [2607:f8b0:400d:c0d::232])
        by mx.google.com with ESMTPS id 12si5817779qtm.506.2017.07.25.11.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:05:12 -0700 (PDT)
Received: by mail-qt0-x232.google.com with SMTP id v29so13172182qtv.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:05:11 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:05:10 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 03/23] percpu: remove has_reserved from pcpu_chunk
Message-ID: <20170725180509.GC18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-4-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-4-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:00PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> Prior this variable was used to manage statistics when the first chunk
> had a reserved region. The previous patch introduced start_offset to
> keep track of the offset by value rather than boolean. Therefore,
> has_reserved can be removed.
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
