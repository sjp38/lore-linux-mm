Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id B98456B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 17:07:33 -0400 (EDT)
Received: by iebgx4 with SMTP id gx4so21431223ieb.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 14:07:33 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y1si2256904icv.44.2015.06.16.14.07.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 14:07:33 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:07:21 -0700
From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC NEXT] mm: Fix suspicious RCU usage at
 kernel/sched/core.c:7318
Message-ID: <20150616210720.GC3958923@devbig242.prn2.facebook.com>
References: <1434403518-5308-1-git-send-email-Larry.Finger@lwfinger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1434403518-5308-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Tejun Heo <tj@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel Team <kernel-team@fb.com>

On Mon, Jun 15, 2015 at 04:25:18PM -0500, Larry Finger wrote:
> Additional backtrace lines are truncated. In addition, the above splat is
> followed by several "BUG: sleeping function called from invalid context
> at mm/slub.c:1268" outputs. As suggested by Martin KaFai Lau, these are the
> clue to the fix. Routine kmemleak_alloc_percpu() always uses GFP_KERNEL
> for its allocations, whereas it should use the value input to pcpu_alloc().
Just a minor nit, 'kmemleak_alloc_percpu() should follow the gfp from
per_alloc()' may be a more accurate title to describe the patch.

Acked-by: Martin KaFai Lau <kafai@fb.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
