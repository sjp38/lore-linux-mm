Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B609B6B000D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 11:48:44 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u130-v6so1363008pgc.0
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:48:44 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e123-v6si12708102pfe.335.2018.07.11.08.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 08:48:43 -0700 (PDT)
Message-ID: <1531323904.13297.26.camel@intel.com>
Subject: Re: [RFC PATCH v2 17/27] x86/cet/shstk: User-mode shadow stack
 support
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 08:45:04 -0700
In-Reply-To: <20180711093454.GX2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-18-yu-cheng.yu@intel.com>
	 <20180711093454.GX2476@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 11:34 +0200, Peter Zijlstra wrote:
> On Tue, Jul 10, 2018 at 03:26:29PM -0700, Yu-cheng Yu wrote:
> > 
> > +/* MSR_IA32_U_CET and MSR_IA32_S_CET bits */
> > +#define MSR_IA32_CET_SHSTK_EN		0x0000000000000001
> > +#define MSR_IA32_CET_WRSS_EN		0x0000000000000002
> > +#define MSR_IA32_CET_ENDBR_EN		0x0000000000000004
> > +#define MSR_IA32_CET_LEG_IW_EN		0x0000000000000008
> > +#define MSR_IA32_CET_NO_TRACK_EN	0x0000000000000010
> Do those want a ULL literal suffix?

I will fix it.
