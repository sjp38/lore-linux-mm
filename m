Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7FF6B000A
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:45:26 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b5-v6so14446583ple.20
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 01:45:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f11-v6si18134224pga.463.2018.07.11.01.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Jul 2018 01:45:25 -0700 (PDT)
Date: Wed, 11 Jul 2018 10:45:18 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v2 10/27] x86/mm: Introduce _PAGE_DIRTY_SW
Message-ID: <20180711084518.GQ2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-11-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180710222639.8241-11-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, Jul 10, 2018 at 03:26:22PM -0700, Yu-cheng Yu wrote:
> +	pte = pte_clear_flags(pte, _PAGE_DIRTY_SW);
>  	return pte_set_flags(pte, _PAGE_DIRTY_HW | _PAGE_SOFT_DIRTY);

Having both _PAGE_DIRTY_SW and _PAGE_SOFT_DIRTY is really confusing.

I'm not sure I have an anwser for this, but urggh.
