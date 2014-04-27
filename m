Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5A56B0035
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 15:47:25 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id la4so7241069vcb.3
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 12:47:24 -0700 (PDT)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id b2si3147772vcy.10.2014.04.27.12.47.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 27 Apr 2014 12:47:24 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id oz11so6987408veb.6
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 12:47:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140427193355.GA17778@laptop.programming.kicks-ass.net>
References: <1398393700.8437.22.camel@pasglop>
	<CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
	<5359CD7C.5020604@zytor.com>
	<CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
	<alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
	<20140425135101.GE11096@twins.programming.kicks-ass.net>
	<alpine.LSU.2.11.1404251215280.5909@eggly.anvils>
	<20140426180711.GM26782@laptop.programming.kicks-ass.net>
	<20140427072034.GC1429@laptop.programming.kicks-ass.net>
	<alpine.LSU.2.11.1404270459160.2688@eggly.anvils>
	<20140427193355.GA17778@laptop.programming.kicks-ass.net>
Date: Sun, 27 Apr 2014 12:47:23 -0700
Message-ID: <CA+55aFys4+G7P+-YtoNn0pUsmGwon+B7RdvFg9qqNbBHz_dg3A@mail.gmail.com>
Subject: Re: Dirty/Access bits vs. page content
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Sun, Apr 27, 2014 at 12:33 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> Oh, absolutely. I wasn't arguing it didn't need it. I was merely
> pointing out that if one was to add to Linus' patch such that we'd only
> do the force_flush for mapping_cap_account_dirty() we wouldn't need
> extra things to deal with shmem.

I think we can certainly add that check if we find out that it is
indeed a performance problem. I *could* imagine loads where people
mmap/munmap shmem regions at a high rate, but don't actually know of
any (remember: for this to matter they also have to dirty the pages).

In the absence of such knowledge, I'd rather not make things more
complex than they already are.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
