Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8C93E6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 15:01:03 -0400 (EDT)
Received: by wgin8 with SMTP id n8so20449787wgi.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 12:01:03 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id k1si4509817wif.77.2015.05.12.12.00.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 12 May 2015 12:01:00 -0700 (PDT)
Date: Tue, 12 May 2015 21:00:14 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v1 11/15] arm/futex: UP futex_atomic_op_inuser() relies
 on disabled preemption
Message-ID: <20150512190014.GD25464@linutronix.de>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
 <1431359540-32227-12-git-send-email-dahi@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1431359540-32227-12-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <dahi@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, yang.shi@windriver.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org

* David Hildenbrand | 2015-05-11 17:52:16 [+0200]:

>The !CONFIG_SMP implementation of futex_atomic_op_inuser() seems to rely
>on disabled preemption to guarantee mutual exclusion.

Yes, this is what the code looks like. It is more the requirement for
ldrex/strex opcodes which are ARMv6+ and so is SMP support (here).
Documentation wise you could replace CONFIG_SMP by 
     __LINUX_ARM_ARCH__ >= 6
in a later patch if you like. This would be more in-sync with
arch/arm/include/asm/cmpxchg.h :)

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
