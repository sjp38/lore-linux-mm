Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DEDF6B026F
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 11:02:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l21-v6so12108357pff.3
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:02:01 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 123-v6si9885390pfd.201.2018.07.11.08.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 08:01:59 -0700 (PDT)
Message-ID: <1531321089.13297.4.camel@intel.com>
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 07:58:09 -0700
In-Reply-To: <20180711094549.GA2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-19-yu-cheng.yu@intel.com>
	 <20180711094549.GA2476@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 11:45 +0200, Peter Zijlstra wrote:
> On Tue, Jul 10, 2018 at 03:26:30PM -0700, Yu-cheng Yu wrote:
> > 
> > diff --git a/arch/x86/lib/x86-opcode-map.txt b/arch/x86/lib/x86-
> > opcode-map.txt
> > index e0b85930dd77..72bb7c48a7df 100644
> > --- a/arch/x86/lib/x86-opcode-map.txt
> > +++ b/arch/x86/lib/x86-opcode-map.txt
> > @@ -789,7 +789,7 @@ f0: MOVBE Gy,My | MOVBE Gw,Mw (66) | CRC32
> > Gd,Eb (F2) | CRC32 Gd,Eb (66&F2)
> > A f1: MOVBE My,Gy | MOVBE Mw,Gw (66) | CRC32 Gd,Ey (F2) | CRC32
> > Gd,Ew (66&F2)
> > A f2: ANDN Gy,By,Ey (v)
> > A f3: Grp17 (1A)
> > -f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey
> > (F2),(v)
> > +f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey
> > (F2),(v) | WRUSS Pq,Qq (66),REX.W
> > A f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v)
> > A f7: BEXTR Gy,Ey,By (v) | SHLX Gy,Ey,By (66),(v) | SARX Gy,Ey,By
> > (F3),(v) | SHRX Gy,Ey,By (F2),(v)
> > A EndTable
> Where are all the other instructions? ISTR that documentation patch
> listing a whole bunch of new instructions, not just wuss.

Currently we only use WRUSS in the kernel code. A Do we want to add all
instructions here?

Yu-cheng
