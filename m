Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B02C06B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 11:41:31 -0400 (EDT)
Subject: Re: [PATCH v4 03/12] Add async PF initialization to PV guest.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1278433500-29884-4-git-send-email-gleb@redhat.com>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
	 <1278433500-29884-4-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 07 Jul 2010 17:41:01 +0200
Message-ID: <1278517261.1946.8.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 2010-07-06 at 19:24 +0300, Gleb Natapov wrote:
> @@ -329,6 +330,8 @@ notrace static void __cpuinit start_secondary(void *u=
nused)
>         per_cpu(cpu_state, smp_processor_id()) =3D CPU_ONLINE;
>         x86_platform.nmi_init();
> =20
> +       kvm_guest_cpu_init();
> +
>         /* enable local interrupts */
>         local_irq_enable();=20

CPU_STARTING hotplug notifier is too early?

called from:
   start_secondary()
     smp_callin()
       notify_cpu_starting()=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
