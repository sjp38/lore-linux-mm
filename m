Subject: Re: 2.5.70-mm4
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <20030603231827.0e635332.akpm@digeo.com>
References: <20030603231827.0e635332.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 04 Jun 2003 08:55:19 -0500
Message-Id: <1054734923.8311.149.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

See bug 772 - http://bugme.osdl.org/show_bug.cgi?id=772
----------------------
CC      kernel/ksyms.o
kernel/ksyms.c:490: `__preempt_spin_lock' undeclared here (not in a
function)
kernel/ksyms.c:490: initializer element is not constant
kernel/ksyms.c:490: (near initialization for
`__ksymtab___preempt_spin_lock.value')
kernel/ksyms.c:491: `__preempt_write_lock' undeclared here (not in a
function)
kernel/ksyms.c:491: initializer element is not constant
kernel/ksyms.c:491: (near initialization for
`__ksymtab___preempt_write_lock.value')
make[1]: *** [kernel/ksyms.o] Error 1
make: *** [kernel] Error 2

It looks like this got broken in /include/linux/spinlock.h:
#if defined(CONFIG_SMP) && defined(CONFIG_PREEMPT) &&
!defined(CONFIG_DEBUG_EVENTLOG)
void __preempt_spin_lock(spinlock_t *lock);
void __preempt_write_lock(rwlock_t *lock);
...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
