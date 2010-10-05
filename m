Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BA1906B004A
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 22:36:54 -0400 (EDT)
Message-ID: <4CAA8F36.5050608@redhat.com>
Date: Mon, 04 Oct 2010 22:36:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 09/12] Inject asynchronous page fault into a PV guest
 if page is swapped out.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-10-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-10-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 10/04/2010 11:56 AM, Gleb Natapov wrote:
> Send async page fault to a PV guest if it accesses swapped out memory.
> Guest will choose another task to run upon receiving the fault.
>
> Allow async page fault injection only when guest is in user mode since
> otherwise guest may be in non-sleepable context and will not be able
> to reschedule.
>
> Vcpu will be halted if guest will fault on the same page again or if
> vcpu executes kernel code.
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
