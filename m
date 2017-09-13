Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3193A6B0253
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 03:43:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m127so2156516wmm.3
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 00:43:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 75sor160979wma.77.2017.09.13.00.43.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 00:43:05 -0700 (PDT)
Date: Wed, 13 Sep 2017 09:43:01 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 00/10] PCID and improved laziness
Message-ID: <20170913074301.rivpgoaf7juvwkha@gmail.com>
References: <cover.1498751203.git.luto@kernel.org>
 <CALBSrqDW6pGjHxOmzfnkY_KoNeH6F=pTb8-tJ8r-zbu4prw9HQ@mail.gmail.com>
 <1505244724.4482.78.camel@intel.com>
 <428E07CE-6F76-4137-B568-B9794735A51F@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <428E07CE-6F76-4137-B568-B9794735A51F@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>, x86@kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, torvalds@linux-foundation.org, akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org, nadav.amit@gmail.com, riel@redhat.com, "Hansen, Dave" <dave.hansen@intel.com>, arjan@linux.intel.com, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, "Shankar, Ravi V" <ravi.v.shankar@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, "Yu, Fenghua" <fenghua.yu@intel.com>


* Andy Lutomirski <luto@amacapital.net> wrote:

> I'm on my way to LPC, so I can't  easily work on this right this instant.
> 
> Can you try this branch, though?
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/commit/?h=x86/fixes&id=cb88ae619b4c3d832d224f2c641849dc02aed864

Any objections against me applying these fixes directly and getting them to Linus 
later today, to not widen the window of breakage any further?

I'll also apply:

   x86/mm/64: Initialize CR4.PCIDE early

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
