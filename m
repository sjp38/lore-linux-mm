Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A17416B006A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 04:24:55 -0500 (EST)
Date: Mon, 2 Nov 2009 10:24:49 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 09/11] Maintain preemptability count even for
	!CONFIG_PREEMPT kernels
Message-ID: <20091102092449.GD8933@elte.hu>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-10-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1257076590-29559-10-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Gleb Natapov <gleb@redhat.com> wrote:

> Do not preempt kernel. Just maintain counter to know if task can sleep.
> 
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> ---
>  include/linux/hardirq.h |    6 ++----
>  include/linux/preempt.h |   22 ++++++++++++++++------
>  kernel/sched.c          |    6 ------
>  lib/kernel_lock.c       |    1 +
>  4 files changed, 19 insertions(+), 16 deletions(-)

Lack of explanation in the changelog and lack of Cc:s.

This whole patch-set should be Cc:-ed to a lot more people, and the acks 
of various maintainers are needed before it can be applied.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
