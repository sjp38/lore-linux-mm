Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E357A6B0078
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 22:37:31 -0400 (EDT)
Message-ID: <4CAA8F5F.1000008@redhat.com>
Date: Mon, 04 Oct 2010 22:37:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 12/12] Send async PF when guest is not in userspace
 too.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-13-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-13-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 10/04/2010 11:56 AM, Gleb Natapov wrote:
> If guest indicates that it can handle async pf in kernel mode too send
> it, but only if interrupts are enabled.
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
