Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 015526B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:06:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id s66so50035659wrc.15
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 23:06:08 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id g50si3447974wrd.40.2017.03.27.23.06.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 23:06:07 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id w43so16441208wrb.1
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 23:06:07 -0700 (PDT)
Date: Tue, 28 Mar 2017 08:06:04 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/8] x86/boot: Detect 5-level paging support
Message-ID: <20170328060604.GA20135@gmail.com>
References: <20170327162925.16092-1-kirill.shutemov@linux.intel.com>
 <20170327162925.16092-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170327162925.16092-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> +#ifdef CONFIG_X86_5LEVEL
> +#define DISABLE_LA57	0
> +#else
> +#define DISABLE_LA57	(1<<(X86_FEATURE_LA57 & 31))
> +#endif

> +#ifdef CONFIG_X86_5LEVEL
> +# define NEED_LA57	(1<<(X86_FEATURE_LA57 & 31))
> +#else
> +# define NEED_LA57	0
> +#endif

Please use consistent style.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
