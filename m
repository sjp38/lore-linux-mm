Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D3AC46006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 09:24:59 -0400 (EDT)
Date: Thu, 8 Jul 2010 16:24:43 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v4 03/12] Add async PF initialization to PV guest.
Message-ID: <20100708132443.GW4689@redhat.com>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
 <1278433500-29884-4-git-send-email-gleb@redhat.com>
 <1278517261.1946.8.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278517261.1946.8.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 07, 2010 at 05:41:01PM +0200, Peter Zijlstra wrote:
> On Tue, 2010-07-06 at 19:24 +0300, Gleb Natapov wrote:
> > @@ -329,6 +330,8 @@ notrace static void __cpuinit start_secondary(void *unused)
> >         per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
> >         x86_platform.nmi_init();
> >  
> > +       kvm_guest_cpu_init();
> > +
> >         /* enable local interrupts */
> >         local_irq_enable(); 
> 
> CPU_STARTING hotplug notifier is too early?
> 
Actually no. I will move this call into cpu notifier.

> called from:
>    start_secondary()
>      smp_callin()
>        notify_cpu_starting() 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
