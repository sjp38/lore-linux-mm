Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id B8F016B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 13:45:24 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id j11so57011ywa.1
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 10:45:24 -0700 (PDT)
Received: from mail-yw0-x229.google.com (mail-yw0-x229.google.com. [2607:f8b0:4002:c05::229])
        by mx.google.com with ESMTPS id d12si722642ybm.576.2017.06.20.10.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 10:45:23 -0700 (PDT)
Received: by mail-yw0-x229.google.com with SMTP id l75so55291584ywc.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 10:45:23 -0700 (PDT)
Date: Tue, 20 Jun 2017 13:45:21 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/4] percpu: add basic stats and tracepoints to percpu
 allocator
Message-ID: <20170620174521.GD21326@htj.duckdns.org>
References: <20170619232832.27116-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170619232832.27116-1-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jun 19, 2017 at 07:28:28PM -0400, Dennis Zhou wrote:
> There is limited visibility into the percpu memory allocator making it hard to
> understand usage patterns. Without these concrete numbers, we are left to
> conjecture about the correctness of percpu memory patterns and usage.
> Additionally, there is no mechanism to review the correctness/efficiency of the
> current implementation.
> 
> This patchset address the following:
> - Adds basic statistics to reason about the number of allocations over the
>   lifetime, allocation sizes, and fragmentation.
> - Adds tracepoints to enable better debug capabilities as well as the ability
>   to review allocation requests and corresponding decisions.
> 
> This patchiest contains the following four patches:
> 0001-percpu-add-missing-lockdep_assert_held-to-func-pcpu_.patch
> 0002-percpu-migrate-percpu-data-structures-to-internal-he.patch
> 0003-percpu-expose-statistics-about-percpu-memory-via-deb.patch
> 0004-percpu-add-tracepoint-support-for-percpu-memory.patch

Applied to percpu/for-4.13.  I had to update 0002 because of the
recent __ro_after_init changes.  Can you please see whether I made any
mistakes while updating it?

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git for-4.13

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
