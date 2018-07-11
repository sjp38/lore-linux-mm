Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85C116B000A
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:21:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id i123-v6so7863261pfc.13
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 02:21:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 13-v6si19940070plb.463.2018.07.11.02.21.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Jul 2018 02:21:24 -0700 (PDT)
Date: Wed, 11 Jul 2018 11:21:17 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v2 10/27] x86/mm: Introduce _PAGE_DIRTY_SW
Message-ID: <20180711092117.GV2476@hirez.programming.kicks-ass.net>
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
> +static inline bool is_shstk_pte(pte_t pte)
> +{
> +	pteval_t val;
> +
> +	val = pte_flags(pte) & (_PAGE_RW | _PAGE_DIRTY_HW);
> +	return (val == _PAGE_DIRTY_HW);
> +}

That's against naming convention here.

static inline bool pte_shstk(pte_t pte)
{
	return pte_flags(pte) & (_PAGE_RW | _PAGE_DIRTY_HW) == _PAGE_DIRTY_HW;
}

would be more in style with the rest of this code.
