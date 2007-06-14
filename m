Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l5E6O4RX022992
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 23:24:04 -0700
Received: from py-out-1112.google.com (pybu77.prod.google.com [10.34.97.77])
	by zps38.corp.google.com with ESMTP id l5E6NcfM010680
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 23:24:00 -0700
Received: by py-out-1112.google.com with SMTP id u77so803892pyb
        for <linux-mm@kvack.org>; Wed, 13 Jun 2007 23:23:59 -0700 (PDT)
Message-ID: <65dd6fd50706132323i9c760f4m6e23687914d0c46e@mail.gmail.com>
Date: Wed, 13 Jun 2007 23:23:59 -0700
From: "Ollie Wild" <aaw@google.com>
Subject: Re: [patch 0/3] no MAX_ARG_PAGES -v2
In-Reply-To: <617E1C2C70743745A92448908E030B2A01AF860A@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070613100334.635756997@chello.nl>
	 <617E1C2C70743745A92448908E030B2A01AF860A@scsmsx411.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On 6/13/07, Luck, Tony <tony.luck@intel.com> wrote:
> Above 5Mbytes, I started seeing problems.  The line/word/char
> counts from "wc" started being "0 0 0".  Not sure if this is
> a problem in "wc" dealing with a single line >5MBytes, or some
> other problem (possibly I was exceeding the per-process stack
> limit which is only 8MB on that machine).

Interesting.  If you're exceeding your stack ulimit, you should be
seeing either an "argument list too long" message or getting a
SIGSEGV.  Have you tried bypassing wc and piping the output straight
to a file?

Ollie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
