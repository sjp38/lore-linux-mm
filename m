Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7B16B02C3
	for <linux-mm@kvack.org>; Mon, 29 May 2017 16:39:16 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t81so25672644qke.2
        for <linux-mm@kvack.org>; Mon, 29 May 2017 13:39:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i24si10751586qte.180.2017.05.29.13.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 13:39:15 -0700 (PDT)
Message-ID: <1496090352.29205.71.camel@redhat.com>
Subject: Re: [PATCH v4 2/8] x86/mm: Change the leave_mm() condition for
 local TLB flushes
From: Rik van Riel <riel@redhat.com>
Date: Mon, 29 May 2017 16:39:12 -0400
In-Reply-To: <61de238db6d9c9018db020c41047ce32dac64488.1495990440.git.luto@kernel.org>
References: <cover.1495990440.git.luto@kernel.org>
	 <61de238db6d9c9018db020c41047ce32dac64488.1495990440.git.luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Sun, 2017-05-28 at 10:00 -0700, Andy Lutomirski wrote:
> On a remote TLB flush, we leave_mm() if we're TLBSTATE_LAZY.A A For a
> local flush_tlb_mm_range(), we leave_mm() if !current->mm.A A These
> are approximately the same condition -- the scheduler sets lazy TLB
> mode when switching to a thread with no mm.
> 
> I'm about to merge the local and remote flush code, but for ease of
> verifying and bisecting the patch, I want the local and remote flush
> behavior to match first.A A This patch changes the local code to match
> the remote code.
> 
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Arjan van de Ven <arjan@linux.intel.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
