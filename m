Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DFBD16B0246
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 12:18:00 -0400 (EDT)
Message-ID: <4C34A8A3.2070204@redhat.com>
Date: Wed, 07 Jul 2010 12:17:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 01/12] Move kvm_smp_prepare_boot_cpu() from kvmclock.c
 to kvm.c.
References: <1278433500-29884-1-git-send-email-gleb@redhat.com> <1278433500-29884-2-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-2-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 07/06/2010 12:24 PM, Gleb Natapov wrote:
> Async PF also needs to hook into smp_prepare_boot_cpu so move the hook
> into generic code.
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
