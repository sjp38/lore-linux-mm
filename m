Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 244156B025E
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 11:20:20 -0500 (EST)
Received: by pacej9 with SMTP id ej9so189120757pac.2
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 08:20:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id qp8si10311048pac.135.2015.11.30.08.20.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 08:20:19 -0800 (PST)
Date: Mon, 30 Nov 2015 17:20:00 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: WARNING in handle_mm_fault
Message-ID: <20151130162000.GM17308@twins.programming.kicks-ass.net>
References: <CACT4Y+Zn+mK37-mvqDQTyt1Psp6HT2heT0e937SO24F7V1q7PA@mail.gmail.com>
 <201511260027.CCC26590.SOHFMQLVJOtFOF@I-love.SAKURA.ne.jp>
 <CACT4Y+ZdF09hOnb_bL4GNjytSMMGvNde8=9pdZt6gZQB1sp0hQ@mail.gmail.com>
 <20151125173730.GS27283@dhcp22.suse.cz>
 <CACT4Y+Y0EESD_HhgGE2pWPqfJsDgvSny=ZMfP1ewaSzd6z_bLg@mail.gmail.com>
 <201511262033.EAB48965.FVJOOOMLFHStFQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511262033.EAB48965.FVJOOOMLFHStFQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: dvyukov@google.com, syzkaller@googlegroups.com, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kcc@google.com, glider@google.com, sasha.levin@oracle.com, edumazet@google.com, gthelen@google.com, tj@kernel.org

On Thu, Nov 26, 2015 at 08:33:05PM +0900, Tetsuo Handa wrote:

> By the way, does use of "unsigned char" than "unsigned" save some bytes?

There are architectures that cannot do independent byte writes. Best
leave it a machine word unless there's a real pressing reason otherwise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
