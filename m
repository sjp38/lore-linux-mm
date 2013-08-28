Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 6DD596B0033
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 21:27:19 -0400 (EDT)
Date: Tue, 27 Aug 2013 18:26:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2013-08-27-16-51 uploaded
Message-Id: <20130827182616.f9396ed6.akpm@linux-foundation.org>
In-Reply-To: <521D494F.1010507@codeaurora.org>
References: <20130827235227.99DB95A41D6@corp2gmr1-2.hot.corp.google.com>
	<521D494F.1010507@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Boyd <sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, voice.shen@atmel.com, Russell King - ARM Linux <linux@arm.linux.org.uk>

On Tue, 27 Aug 2013 17:50:23 -0700 Stephen Boyd <sboyd@codeaurora.org> wrote:

> On 08/27/13 16:52, akpm@linux-foundation.org wrote:
> > * kernel-time-sched_clockc-correct-the-comparison-parameter-of-mhz.patch
> >
> 
> I believe Russell nacked this change[1]? This should probably be dropped
> unless there's been more discussion. Or maybe reworked into a comment in
> the code that doesn't lead to the same change again.
> 
> [1] https://lkml.org/lkml/2013/8/7/95

Well OK, but the code looks totally wrong.  Care to send a comment patch
so the next confused person doesn't "fix" it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
