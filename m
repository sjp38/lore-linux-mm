Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6BD6B0273
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:40:39 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f31-v6so5659610plb.10
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:40:39 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 83-v6si16793977pgg.663.2018.07.10.16.40.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:40:38 -0700 (PDT)
Subject: Re: [RFC PATCH v2 17/27] x86/cet/shstk: User-mode shadow stack
 support
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-18-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <65f46bde-b197-6198-2e38-5692f5ca53af@linux.intel.com>
Date: Tue, 10 Jul 2018 16:40:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-18-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> +static __init int setup_disable_shstk(char *s)
> +{
> +	/* require an exact match without trailing characters */
> +	if (strlen(s))
> +		return 0;
> +
> +	if (!boot_cpu_has(X86_FEATURE_SHSTK))
> +		return 1;
> +
> +	setup_clear_cpu_cap(X86_FEATURE_SHSTK);
> +	pr_info("x86: 'no_cet_shstk' specified, disabling Shadow Stack\n");
> +	return 1;
> +}
> +__setup("no_cet_shstk", setup_disable_shstk);

Why do we need a boot-time disable for this?
