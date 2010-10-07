Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 67E316B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:30:19 -0400 (EDT)
Message-ID: <4CADCB4E.60509@redhat.com>
Date: Thu, 07 Oct 2010 15:29:50 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/12] Halt vcpu if page it tries to access is swapped
 out.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-3-git-send-email-gleb@redhat.com> <4CAD97D0.70100@redhat.com> <4CADCA1E.1080207@redhat.com>
In-Reply-To: <4CADCA1E.1080207@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/07/2010 03:24 PM, Rik van Riel wrote:
> On 10/07/2010 05:50 AM, Avi Kivity wrote:
>
>>> +static bool can_do_async_pf(struct kvm_vcpu *vcpu)
>>> +{
>>> + if (unlikely(!irqchip_in_kernel(vcpu->kvm) ||
>>> + kvm_event_needs_reinjection(vcpu)))
>>> + return false;
>>> +
>>> + return kvm_x86_ops->interrupt_allowed(vcpu);
>>> +}
>>
>> Strictly speaking, if the cpu can handle NMIs it can take an apf?
>
> Strictly speaking, yes.
>
> However, it may not be able to DO anything with it, since
> it won't be able to reschedule the context it's running :)
>

I was thinking about keeping the watchdog nmi handler responsive.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
