Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE4D6B0433
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:54:42 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id p5so35221319ybg.10
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:54:42 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id z191si4442022ywa.515.2017.06.21.10.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 10:54:41 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id s127so11116262ywg.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:54:41 -0700 (PDT)
Date: Wed, 21 Jun 2017 13:54:39 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] percpu: fix early calls for spinlock in pcpu_stats
Message-ID: <20170621175439.GA10139@htj.duckdns.org>
References: <20170619232832.27116-1-dennisz@fb.com>
 <20170619232832.27116-5-dennisz@fb.com>
 <20170621161836.tv67op4hokja35bc@sasha-lappy>
 <20170621175245.GA99514@dennisz-mbp.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170621175245.GA99514@dennisz-mbp.dhcp.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-team@fb.com" <kernel-team@fb.com>

On Wed, Jun 21, 2017 at 01:52:46PM -0400, Dennis Zhou wrote:
> From 2c06e795162cb306c9707ec51d3e1deadb37f573 Mon Sep 17 00:00:00 2001
> From: Dennis Zhou <dennisz@fb.com>
> Date: Wed, 21 Jun 2017 10:17:09 -0700
> 
> Commit 30a5b5367ef9 ("percpu: expose statistics about percpu memory via
> debugfs") introduces percpu memory statistics. pcpu_stats_chunk_alloc
> takes the spin lock and disables/enables irqs on creation of a chunk. Irqs
> are not enabled when the first chunk is initialized and thus kernels are
> failing to boot with kernel debugging enabled. Fixed by changing _irq to
> _irqsave and _irqrestore.
> 
> Fixes: 30a5b5367ef9 ("percpu: expose statistics about percpu memory via debugfs")
> Signed-off-by: Dennis Zhou <dennisz@fb.com>
> Reported-by: Alexander Levin <alexander.levin@verizon.com>

Applied to percpu/for-4.13.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
