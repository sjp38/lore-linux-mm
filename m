Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 204E86B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 00:47:09 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so71047038pgc.6
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 21:47:09 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id g7si4011447plk.69.2017.03.15.21.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 21:47:08 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id o126so18521018pfb.3
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 21:47:08 -0700 (PDT)
Date: Thu, 16 Mar 2017 13:47:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [mmotm] "x86/atomic: move __arch_atomic_add_unless out of line"
 build error
Message-ID: <20170316044704.GA729@jagdpanzerIV.localdomain>
Reply-To: 20170315021431.13107-3-andi@firstfloor.org
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

Hello,

commit 4f86a82ff7df ("x86/atomic: move __arch_atomic_add_unless out of line")
moved __arch_atomic_add_unless() out atomic.h and new KASAN atomic
instrumentation [1] can't see it anymore


In file included from ./arch/x86/include/asm/atomic.h:257:0,
                 from ./include/linux/atomic.h:4,
                 from ./include/asm-generic/qspinlock_types.h:28,
                 from ./arch/x86/include/asm/spinlock_types.h:26,
                 from ./include/linux/spinlock_types.h:13,
                 from kernel/bounds.c:13:
./include/asm-generic/atomic-instrumented.h: In function a??__atomic_add_unlessa??:
./include/asm-generic/atomic-instrumented.h:70:9: error: implicit declaration of function a??__arch_atomic_add_unlessa?? [-Werror=implicit-function-declaration]
  return __arch_atomic_add_unless(v, a, u);
         ^~~~~~~~~~~~~~~~~~~~~~~~


so we need a declaration of __arch_atomic_add_unless() in arch/x86/include/asm/atomic.h


[1] lkml.kernel.org/r/7e450175a324bf93c602909c711bc34715d8e8f2.1489519233.git.dvyukov@google.com

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
