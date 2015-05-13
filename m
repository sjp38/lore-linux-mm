Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 726856B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 04:21:41 -0400 (EDT)
Received: by wgic8 with SMTP id c8so35263686wgi.1
        for <linux-mm@kvack.org>; Wed, 13 May 2015 01:21:41 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id lg1si31578284wjc.136.2015.05.13.01.21.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 13 May 2015 01:21:40 -0700 (PDT)
Date: Wed, 13 May 2015 10:19:56 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v1 11/15] arm/futex: UP futex_atomic_op_inuser() relies
 on disabled preemption
Message-ID: <20150513081956.GB21106@linutronix.de>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
 <1431359540-32227-12-git-send-email-dahi@linux.vnet.ibm.com>
 <20150512190014.GD25464@linutronix.de>
 <20150513093812.65fdac96@thinkpad-w530>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150513093812.65fdac96@thinkpad-w530>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <dahi@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, yang.shi@windriver.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org

* David Hildenbrand | 2015-05-13 09:38:12 [+0200]:

>Thanks, I'll include it in the next version.
>
>So I assume the cleanest thing to do would be:
>
>#if __LINUX_ARM_ARCH__ < 6
>	preempt_disable();
>#endif

Correct. But also for futex_atomic_cmpxchg_inatomic() which also behind
CONFIG_SMP curtain. That is why I suggested a new patch :)

>David

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
