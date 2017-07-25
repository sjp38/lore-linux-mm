Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1AC16B02FD
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:15:37 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id f72so101821509ywb.4
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:15:37 -0700 (PDT)
Received: from mail-yw0-x231.google.com (mail-yw0-x231.google.com. [2607:f8b0:4002:c05::231])
        by mx.google.com with ESMTPS id t66si3595004ywf.91.2017.07.25.11.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:15:37 -0700 (PDT)
Received: by mail-yw0-x231.google.com with SMTP id x125so73378679ywa.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:15:36 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:15:35 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 07/23] percpu: setup_first_chunk rename schunk/dchunk
 to chunk
Message-ID: <20170725181535.GG18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-8-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-8-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:04PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> There is no need to have the static chunk and dynamic chunk be named
> separately as the allocations are sequential. This preemptively solves
> the misnomer problem with the base_addrs being moved up in the following
> patch. It also removes a ternary operation deciding the first chunk.
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
