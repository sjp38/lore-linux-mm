Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1896B0256
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:08:17 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so61952065wib.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:08:16 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id pc3si5971993wic.24.2015.07.31.08.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:08:15 -0700 (PDT)
Date: Fri, 31 Jul 2015 17:08:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [tip:x86/mm] x86/mm/mtrr: Clean up mtrr_type_lookup()
Message-ID: <20150731150806.GX25159@twins.programming.kicks-ass.net>
References: <1431714237-880-6-git-send-email-toshi.kani@hp.com>
 <1432628901-18044-6-git-send-email-bp@alien8.de>
 <tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
 <20150731131802.GW25159@twins.programming.kicks-ass.net>
 <20150731144452.GA8106@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150731144452.GA8106@nazgul.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: mingo@kernel.org, hpa@zytor.com, dvlasenk@redhat.com, bp@suse.de, akpm@linux-foundation.org, brgerst@gmail.com, tglx@linutronix.de, linux-mm@kvack.org, luto@amacapital.net, mcgrof@suse.com, toshi.kani@hp.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-tip-commits@vger.kernel.org

On Fri, Jul 31, 2015 at 04:44:52PM +0200, Borislav Petkov wrote:
> On Fri, Jul 31, 2015 at 03:18:02PM +0200, Peter Zijlstra wrote:
> > Using these functions with preemption enabled is racy against MTRR
> > updates. And if that race is ok, at the very least explain that it is
> > indeed racy and why this is not a problem.
> 
> Right, so Luis has been working on burying direct MTRR access so
> after that work is done, we'll be using only PAT for changing memory
> attributes. Look at arch_phys_wc_add() and all those fbdev users of
> mtrr_add() which get converted to that thing...

Drivers don't do those lookups afaict.

But its things like set_memory_XX(), and afaict that's all buggy against
MTRR modifications.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
