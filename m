Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6E5FB6B004A
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 21:21:15 -0400 (EDT)
Message-ID: <4CAA7D7B.5000504@redhat.com>
Date: Mon, 04 Oct 2010 21:20:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/12] Halt vcpu if page it tries to access is swapped
 out.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-3-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-3-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 10/04/2010 11:56 AM, Gleb Natapov wrote:
> If a guest accesses swapped out memory do not swap it in from vcpu thread
> context. Schedule work to do swapping and put vcpu into halted state
> instead.
>
> Interrupts will still be delivered to the guest and if interrupt will
> cause reschedule guest will continue to run another task.
>
> Signed-off-by: Gleb Natapov<gleb@redhat.com>

This seems quite different from the last version, but it
looks fine to me.

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
