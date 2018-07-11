Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5429C6B000C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 12:18:51 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 31-v6so15243299plf.19
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:18:51 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k33-v6si19235359pld.269.2018.07.11.09.18.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 09:18:50 -0700 (PDT)
Message-ID: <1531325701.13297.32.camel@intel.com>
Subject: Re: [RFC PATCH v2 08/27] mm: Introduce VM_SHSTK for shadow stack
 memory
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 09:15:01 -0700
In-Reply-To: <20180711083412.GP2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-9-yu-cheng.yu@intel.com>
	 <20180711083412.GP2476@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 10:34 +0200, Peter Zijlstra wrote:
> On Tue, Jul 10, 2018 at 03:26:20PM -0700, Yu-cheng Yu wrote:
> > 
> > VM_SHSTK indicates a shadow stack memory area.
> > 
> > A shadow stack PTE must be read-only and dirty.A A For non shadow
> > stack, we use a spare bit of the 64-bit PTE for dirty.A A The PTE
> > changes are in the next patch.
> This doesn't make any sense.. the $subject and the patch seem
> completely
> unrelated to this Changelog.

I was trying to say why this is only defined for 64-bit. A I will fix
it.

Yu-cheng
