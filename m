Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 15C6B6B006A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 00:28:37 -0400 (EDT)
Message-ID: <4C3553E2.7020607@redhat.com>
Date: Thu, 08 Jul 2010 00:28:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 11/12] Let host know whether the guest can handle async
 PF in non-userspace context.
References: <1278433500-29884-1-git-send-email-gleb@redhat.com> <1278433500-29884-12-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-12-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 07/06/2010 12:24 PM, Gleb Natapov wrote:
> If guest can detect that it runs in non-preemptable context it can
> handle async PFs at any time, so let host know that it can send async
> PF even if guest cpu is not in userspace.

The code looks correct.  One question though - is there a
reason to implement the userspace-only async PF path at
all, since the handling of async PF in non-userspace context
is introduced simultaneously?

> Signed-off-by: Gleb Natapov<gleb@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
