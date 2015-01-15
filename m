Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 59BF46B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 14:39:42 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id n8so12557311qaq.4
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 11:39:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l6si3233798qca.20.2015.01.15.11.39.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 11:39:41 -0800 (PST)
Date: Thu, 15 Jan 2015 20:38:39 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 4/8] x86/spinlock: Leftover conversion
	ACCESS_ONCE->READ_ONCE
Message-ID: <20150115193839.GA28727@redhat.com>
References: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com> <1421312314-72330-5-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421312314-72330-5-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org

On 01/15, Christian Borntraeger wrote:
>
> --- a/arch/x86/include/asm/spinlock.h
> +++ b/arch/x86/include/asm/spinlock.h
> @@ -186,7 +186,7 @@ static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
>  	__ticket_t head = ACCESS_ONCE(lock->tickets.head);
>  
>  	for (;;) {
> -		struct __raw_tickets tmp = ACCESS_ONCE(lock->tickets);
> +		struct __raw_tickets tmp = READ_ONCE(lock->tickets);

Agreed, but what about another ACCESS_ONCE() above?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
