Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f54.google.com (mail-qe0-f54.google.com [209.85.128.54])
	by kanga.kvack.org (Postfix) with ESMTP id 87AF76B0035
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 13:34:27 -0500 (EST)
Received: by mail-qe0-f54.google.com with SMTP id cy11so3176417qeb.41
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 10:34:27 -0800 (PST)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id t7si9618962qar.27.2013.12.15.10.34.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Dec 2013 10:34:26 -0800 (PST)
Received: by mail-vc0-f182.google.com with SMTP id lc6so2567257vcb.41
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 10:34:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131215155539.GM11295@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
	<CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
	<20131215155539.GM11295@suse.de>
Date: Sun, 15 Dec 2013 10:34:25 -0800
Message-ID: <CA+55aFz5ZTEiEELhPaQd97TorAKjqrKCmJc9O0NE1Nyri65Pzw@mail.gmail.com>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Dec 15, 2013 at 7:55 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> Short answer -- There appears to be a second bug where 3.13-rc3 is less
> fair to threads getting time on the CPU.

Hmm.  Can you point me at the (fixed) microbenchmark you mention?

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
