Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9D5F96B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:37:20 -0400 (EDT)
Message-ID: <4CADCCF8.5000408@redhat.com>
Date: Thu, 07 Oct 2010 15:36:56 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 11/12] Let host know whether the guest can handle async
 PF in non-userspace context.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-12-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-12-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> If guest can detect that it runs in non-preemptable context it can
> handle async PFs at any time, so let host know that it can send async
> PF even if guest cpu is not in userspace.
>
>
>
>   MSR_KVM_ASYNC_PF_EN: 0x4b564d02
>   	data: Bits 63-6 hold 64-byte aligned physical address of a 32bit memory
> -	area which must be in guest RAM. Bits 5-1 are reserved and should be
> +	area which must be in guest RAM. Bits 5-2 are reserved and should be
>   	zero. Bit 0 is 1 when asynchronous page faults are enabled on the vcpu
> -	0 when disabled.
> +	0 when disabled. Bit 2 is 1 if asynchronous page faults can be injected
> +	when vcpu is in kernel mode.

Please use cpl instead of user mode and kernel mode.  The original terms 
are ambiguous for cpl ==1 || cpl == 2.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
