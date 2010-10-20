Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D26326B00A0
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 07:53:42 -0400 (EDT)
Subject: Re: [PATCH v7 08/12] Handle async PF in a guest.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4CBED71D.7040000@siemens.com>
References: <1287048176-2563-1-git-send-email-gleb@redhat.com>
	 <1287048176-2563-9-git-send-email-gleb@redhat.com>
	 <4CBED71D.7040000@siemens.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Oct 2010 13:53:31 +0200
Message-ID: <1287575611.3488.12.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kiszka <jan.kiszka@siemens.com>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 2010-10-20 at 13:48 +0200, Jan Kiszka wrote:
> > +     case KVM_PV_REASON_PAGE_READY:
> > +             svm->apf_reason = 0;
> > +             local_irq_disable();
> > +             kvm_async_pf_task_wake(fault_address);
> > +             local_irq_enable();
> > +             break;
> 
> That's only available if CONFIG_KVM_GUEST is set, no? Is there anything
> I miss that resolves this dependency automatically? Otherwise, some more
> #ifdef CONFIG_KVM_GUEST might be needed.


Could you please trim your replies?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
