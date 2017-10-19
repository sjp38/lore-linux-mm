Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2FC36B0253
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:32:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y128so521736pfg.5
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 21:32:42 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id d10si5167516pgc.100.2017.10.18.21.32.41
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 21:32:41 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:32:40 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171019043240.GA3310@X58A-UD3R>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <20171018100944.g2mc6yorhtm5piom@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018100944.g2mc6yorhtm5piom@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

On Wed, Oct 18, 2017 at 12:09:44PM +0200, Ingo Molnar wrote:
> BTW., have you attempted limiting the depth of the stack traces? I suspect more 
> than 2-4 are rarely required to disambiguate the calling context.

I did it for you. Let me show you the result.

1. No lockdep

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       2.756558155 seconds time elapsed                    ( +-  0.09% )

2. Lockdep

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       2.968710420 seconds time elapsed                    ( +-  0.12% )

3. Lockdep + Crossrelease 5 entries

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       3.153839636 seconds time elapsed                    ( +-  0.31% )

4. Lockdep + Crossrelease 3 entries

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       3.137205534 seconds time elapsed                    ( +-  0.87% )

5. Lockdep + Crossrelease + This patch

 Performance counter stats for 'qemu_booting_time.sh bzImage' (10 runs):

       2.963669551 seconds time elapsed                    ( +-  0.11% )

And I will add the result in commit message at the next spin.

Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
