Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id E785C6B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 04:56:13 -0400 (EDT)
Received: by widdi4 with SMTP id di4so188698959wid.0
        for <linux-mm@kvack.org>; Wed, 13 May 2015 01:56:13 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id wi9si1277224wjb.98.2015.05.13.01.56.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 13 May 2015 01:56:12 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Wed, 13 May 2015 09:56:10 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2AF7717D8042
	for <linux-mm@kvack.org>; Wed, 13 May 2015 09:56:56 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4D8u7MP7274998
	for <linux-mm@kvack.org>; Wed, 13 May 2015 08:56:07 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4D8tvB7014395
	for <linux-mm@kvack.org>; Wed, 13 May 2015 02:55:59 -0600
Date: Wed, 13 May 2015 10:55:56 +0200
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: Re: [PATCH v1 11/15] arm/futex: UP futex_atomic_op_inuser() relies
 on disabled preemption
Message-ID: <20150513105556.2607d99c@thinkpad-w530>
In-Reply-To: <20150513081956.GB21106@linutronix.de>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
	<1431359540-32227-12-git-send-email-dahi@linux.vnet.ibm.com>
	<20150512190014.GD25464@linutronix.de>
	<20150513093812.65fdac96@thinkpad-w530>
	<20150513081956.GB21106@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, yang.shi@windriver.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org

> * David Hildenbrand | 2015-05-13 09:38:12 [+0200]:
> 
> >Thanks, I'll include it in the next version.
> >
> >So I assume the cleanest thing to do would be:
> >
> >#if __LINUX_ARM_ARCH__ < 6
> >	preempt_disable();
> >#endif
> 
> Correct. But also for futex_atomic_cmpxchg_inatomic() which also behind
> CONFIG_SMP curtain. That is why I suggested a new patch :)
> 
> >David
> 
> Sebastian

Ah, okay I think now I got it :)

So both patches are fine for now, but we should replace CONFIG_SMP
by __LINUX_ARM_ARCH__ >=6 in both file, not only in the code I touch (to make
it map arch/arm/include/asm/cmpxchg.h style).

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
