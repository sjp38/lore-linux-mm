Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9283B6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 11:54:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y190so7810966pgb.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 08:54:47 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n63si4767960pga.24.2017.08.07.08.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 08:54:46 -0700 (PDT)
Date: Mon, 7 Aug 2017 08:54:45 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCHv3 13/13] x86/mm: Offset boot-time paging mode switching
 cost
Message-ID: <20170807155445.GG3946@tassilo.jf.intel.com>
References: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
 <20170807141451.80934-14-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170807141451.80934-14-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
> index 077e8b45784c..6f92e61d35ac 100644
> --- a/arch/x86/entry/entry_64.S
> +++ b/arch/x86/entry/entry_64.S
> @@ -274,7 +274,7 @@ return_from_SYSCALL_64:
>  	 * depending on paging mode) in the address.
>  	 */
>  #ifdef CONFIG_X86_5LEVEL
> -	testl	$1, p4d_folded(%rip)
> +	testl	$1, __p4d_folded(%rip)
>  	jnz	1f


You can use

	ALTERNATIVE "", "jmp 1f", X86_FEATURE_LA57

to do the patching.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
