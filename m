Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D59F26B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 19:12:36 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q62so397206468oih.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 16:12:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d6si8003053ith.99.2016.08.02.16.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 16:12:36 -0700 (PDT)
Date: Tue, 2 Aug 2016 19:12:30 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] x86/mm: Add barriers and document switch_mm()-vs-flush
 synchronization follow-up
Message-ID: <20160802231229.GE32028@t510>
References: <88fb045963d1e51cd14c05c9c4d283a1ccd29c80.1470151425.git.aquini@redhat.com>
 <746D30E7-2F58-42DB-95D8-D50922CAEB7E@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <746D30E7-2F58-42DB-95D8-D50922CAEB7E@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org

On Tue, Aug 02, 2016 at 03:27:06PM -0700, Nadav Amit wrote:
> Rafael Aquini <aquini@redhat.com> wrote:
> 
> > While backporting 71b3c126e611 ("x86/mm: Add barriers and document switch_mm()-vs-flush synchronization")
> > we stumbled across a possibly missing barrier at flush_tlb_page().
> 
> I too noticed it and submitted a similar patch that never got a response [1].
>

As far as I understood Andy's rationale for the original patch you need
a full memory barrier there in flush_tlb_page to get that cache-eviction
race sorted out.

Regards,
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
