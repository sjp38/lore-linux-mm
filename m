Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id A69C36B0032
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 22:43:32 -0400 (EDT)
Received: by oiyy130 with SMTP id y130so7971571oiy.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 19:43:32 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id z9si1769987oey.5.2015.06.16.19.43.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 19:43:31 -0700 (PDT)
Received: by oiyy130 with SMTP id y130so7971473oiy.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 19:43:31 -0700 (PDT)
Message-ID: <5580DED0.3060002@lwfinger.net>
Date: Tue, 16 Jun 2015 21:43:28 -0500
From: Larry Finger <Larry.Finger@lwfinger.net>
MIME-Version: 1.0
Subject: Re: [RFC NEXT] mm: Fix suspicious RCU usage at kernel/sched/core.c:7318
References: <1434403518-5308-1-git-send-email-Larry.Finger@lwfinger.net> <20150616210720.GC3958923@devbig242.prn2.facebook.com>
In-Reply-To: <20150616210720.GC3958923@devbig242.prn2.facebook.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin KaFai Lau <kafai@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel Team <kernel-team@fb.com>

On 06/16/2015 04:07 PM, Martin KaFai Lau wrote:
> On Mon, Jun 15, 2015 at 04:25:18PM -0500, Larry Finger wrote:
>> Additional backtrace lines are truncated. In addition, the above splat is
>> followed by several "BUG: sleeping function called from invalid context
>> at mm/slub.c:1268" outputs. As suggested by Martin KaFai Lau, these are the
>> clue to the fix. Routine kmemleak_alloc_percpu() always uses GFP_KERNEL
>> for its allocations, whereas it should use the value input to pcpu_alloc().
> Just a minor nit, 'kmemleak_alloc_percpu() should follow the gfp from
> per_alloc()' may be a more accurate title to describe the patch.

Do you mean that the subject should be changed?

Larry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
