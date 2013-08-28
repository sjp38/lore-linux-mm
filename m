Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id DEA116B0033
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 14:42:24 -0400 (EDT)
Date: Wed, 28 Aug 2013 11:42:20 -0700
From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: mmotm 2013-08-27-16-51 uploaded
Message-ID: <20130828184218.GB19754@codeaurora.org>
References: <20130827235227.99DB95A41D6@corp2gmr1-2.hot.corp.google.com>
 <521D494F.1010507@codeaurora.org>
 <20130827182616.f9396ed6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130827182616.f9396ed6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, voice.shen@atmel.com, Russell King - ARM Linux <linux@arm.linux.org.uk>

On 08/27, Andrew Morton wrote:
> On Tue, 27 Aug 2013 17:50:23 -0700 Stephen Boyd <sboyd@codeaurora.org> wrote:
> 
> > On 08/27/13 16:52, akpm@linux-foundation.org wrote:
> > > * kernel-time-sched_clockc-correct-the-comparison-parameter-of-mhz.patch
> > >
> > 
> > I believe Russell nacked this change[1]? This should probably be dropped
> > unless there's been more discussion. Or maybe reworked into a comment in
> > the code that doesn't lead to the same change again.
> > 
> > [1] https://lkml.org/lkml/2013/8/7/95
> 
> Well OK, but the code looks totally wrong.  Care to send a comment patch
> so the next confused person doesn't "fix" it?

Sure, how about this?

---8<----
From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH] sched_clock: Document 4Mhz vs 1Mhz decision

Bo Shen sent a patch to change this to 1Mhz instead of 4Mhz but
according to Russell King the use of 4Mhz was intentional. Add a
comment to this effect so that others don't try to change the
code as well.

Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 kernel/time/sched_clock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/time/sched_clock.c b/kernel/time/sched_clock.c
index a326f27..1e9e298 100644
--- a/kernel/time/sched_clock.c
+++ b/kernel/time/sched_clock.c
@@ -128,6 +128,10 @@ void __init setup_sched_clock(u32 (*read)(void), int bits, unsigned long rate)
 	clocks_calc_mult_shift(&cd.mult, &cd.shift, rate, NSEC_PER_SEC, 0);
 
 	r = rate;
+	/*
+	 * Use 4MHz instead of 1MHz so that things like 1.832Mhz show as
+	 * 1832Khz
+	 */
 	if (r >= 4000000) {
 		r /= 1000000;
 		r_unit = 'M';
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
