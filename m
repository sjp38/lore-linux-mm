Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 58E7D6B006A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 00:09:32 -0400 (EDT)
Message-ID: <4C354F67.3090404@redhat.com>
Date: Thu, 08 Jul 2010 00:09:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 08/12] Inject asynchronous page fault into a guest
 if page is swapped out.
References: <1278433500-29884-1-git-send-email-gleb@redhat.com> <1278433500-29884-9-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-9-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 07/06/2010 12:24 PM, Gleb Natapov wrote:
> If guest access swapped out memory do not swap it in from vcpu thread
> context. Setup slow work to do swapping and send async page fault to
> a guest.
>
> Allow async page fault injection only when guest is in user mode since
> otherwise guest may be in non-sleepable context and will not be able to
> reschedule.
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
