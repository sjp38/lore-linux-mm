Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 261516B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 13:22:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id h21so23272209pfk.14
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 10:22:55 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f84si26016097pfh.71.2017.11.27.10.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 10:22:54 -0800 (PST)
Subject: Re: [patch V2 5/5] x86/kaiser: Add boottime disable switch
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.645128754@linutronix.de>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <24359653-5b93-7146-8f65-ac38c3af0069@linux.intel.com>
Date: Mon, 27 Nov 2017 10:22:52 -0800
MIME-Version: 1.0
In-Reply-To: <20171126232414.645128754@linutronix.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On 11/26/2017 03:14 PM, Thomas Gleixner wrote:
> --- a/security/Kconfig
> +++ b/security/Kconfig
> @@ -56,7 +56,7 @@ config SECURITY_NETWORK
>  
>  config KAISER
>  	bool "Remove the kernel mapping in user mode"
> -	depends on X86_64 && SMP && !PARAVIRT
> +	depends on X86_64 && SMP && !PARAVIRT && JUMP_LABEL
>  	help
>  	  This feature reduces the number of hardware side channels by
>  	  ensuring that the majority of kernel addresses are not mapped

One of the reasons for doing the runtime-disable was to get rid of the
!PARAVIRT dependency.  I can add a follow-on here that will act as if we
did "nokaiser" whenever Xen is in play so we can remove this dependency.

I just hope Xen is detectable early enough to do the static patching.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
