Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C16116B0502
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 19:19:06 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id y7so168999oia.15
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 16:19:06 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id c203si81790oib.328.2017.08.22.16.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 16:19:05 -0700 (PDT)
Received: by mail-oi0-x232.google.com with SMTP id r200so1703937oie.2
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 16:19:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFw_-RmdWF6mPHonnqoJcMEmjhvjzcwp5OU7Uwzk3KPNmw@mail.gmail.com>
References: <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <20170822190828.GO32112@worktop.programming.kicks-ass.net>
 <CA+55aFzPt401xpRzd6Qu-WuDNGneR_m7z25O=0YspNi+cLRb8w@mail.gmail.com>
 <20170822193714.GZ28715@tassilo.jf.intel.com> <alpine.DEB.2.20.1708221605220.18344@nuc-kabylake>
 <20170822212408.GC28715@tassilo.jf.intel.com> <CA+55aFw_-RmdWF6mPHonnqoJcMEmjhvjzcwp5OU7Uwzk3KPNmw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 22 Aug 2017 16:19:04 -0700
Message-ID: <CA+55aFxVbeKa4RbqYcs_m3K_W0J_SXY-HeQ7hwJWODkwXs53Eg@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Christopher Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 22, 2017 at 3:52 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The *other* memory policies look fairly sane. They basically have a
> fairly well-defined preferred node for the policy (although the
> "MPOL_INTERLEAVE" looks wrong for a hugepage).  But
> MPOL_PREFERRED/MPOL_F_LOCAL really looks completely broken.

Of course, I don't know if that customer test-case actually triggers
that MPOL_PREFERRED/MPOL_F_LOCAL case at all.

So again, that issue may not even be what is going on.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
