Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 451A06B0390
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:41:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b2so99893688pgc.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 09:41:13 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 2si1564538pgy.24.2017.03.16.09.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 09:41:12 -0700 (PDT)
Date: Thu, 16 Mar 2017 09:41:10 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [mmotm] "x86/atomic: move __arch_atomic_add_unless out of line"
 build error
Message-ID: <20170316164110.GK32070@tassilo.jf.intel.com>
References: <20170316044704.GA729@jagdpanzerIV.localdomain>
 <CACT4Y+asa7rDwjQi_09cYGsgqy0LFRRiCHq3=3t6__VUMLzmXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+asa7rDwjQi_09cYGsgqy0LFRRiCHq3=3t6__VUMLzmXg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: 20170315021431.13107-3-andi@firstfloor.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

> Andi, why did you completely remove __arch_atomic_add_unless() from
> the header? Don't we need at least a declaration there?

Actually it's there in my git version:

I wonder where it disappeared.

-/**
- * __atomic_add_unless - add unless the number is already a given value
- * @v: pointer of type atomic_t
- * @a: the amount to add to v...
- * @u: ...unless v is equal to u.
- *
- * Atomically adds @a to @v, so long as @v was not already @u.
- * Returns the old value of @v.
- */
-static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
-{
-       int c, old;
-       c = atomic_read(v);
-       for (;;) {
-               if (unlikely(c == (u)))
-                       break;
-               old = atomic_cmpxchg((v), c, c + (a));
-               if (likely(old == c))
-                       break;
-               c = old;
-       }
-       return c;
-}
+int __atomic_add_unless(atomic_t *v, int a, int u);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
