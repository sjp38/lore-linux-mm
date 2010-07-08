Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5A7716B0246
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 00:23:16 -0400 (EDT)
Message-ID: <4C35529F.4060204@redhat.com>
Date: Thu, 08 Jul 2010 00:22:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 10/12] Handle async PF in non preemptable context
References: <1278433500-29884-1-git-send-email-gleb@redhat.com> <1278433500-29884-11-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-11-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 07/06/2010 12:24 PM, Gleb Natapov wrote:
> If async page fault is received by idle task or when preemp_count is
> not zero guest cannot reschedule, so do sti; hlt and wait for page to be
> ready. vcpu can still process interrupts while it waits for the page to
> be ready.
>
> Signed-off-by: Gleb Natapov<gleb@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
