Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C41316B0078
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 10:34:19 -0500 (EST)
Subject: Re: [PATCH v2 10/12] Maintain preemptability count even for
 !CONFIG_PREEMPT kernels
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1258985167-29178-11-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
	 <1258985167-29178-11-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 23 Nov 2009 16:34:15 +0100
Message-ID: <1258990455.4531.594.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-23 at 16:06 +0200, Gleb Natapov wrote:
> Do not preempt kernel. Just maintain counter to know if task can be rescheduled.
> Asynchronous page fault may be delivered while spinlock is held or current
> process can't be preempted for other reasons. KVM uses preempt_count() to check if preemptions is allowed and schedule other process if possible. This works
> with preemptable kernels since they maintain accurate information about
> preemptability in preempt_count. This patch make non-preemptable kernel
> maintain accurate information in preempt_count too.

I'm thinking you're going to have to convince some people this won't
slow them down for no good.

Personally I always have PREEMPT=y, but other people seem to feel
strongly about not doing so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
