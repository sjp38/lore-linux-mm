Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EBE516B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:29:15 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o5so76323247qki.2
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:29:15 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id c12si11822364qtd.286.2017.07.25.12.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:29:15 -0700 (PDT)
Received: by mail-qk0-x232.google.com with SMTP id d145so68128008qkc.2
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:29:15 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:29:13 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 18/23] percpu: keep track of the best offset for
 contig hints
Message-ID: <20170725192912.GR18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-19-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-19-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:15PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> This patch makes the contig hint starting offset optimization from the
> previous patch as honest as it can be. For both chunk and block starting
> offsets, make sure it keeps the starting offset with the best alignment.
> 
> The block skip optimization is added in a later patch when the
> pcpu_find_block_fit iterator is swapped in.
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
