Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 66DA76B0260
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:42:15 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z184so19727553pgd.0
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 11:42:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x27sor5247861pfj.105.2017.11.23.11.42.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 11:42:14 -0800 (PST)
Date: Thu, 23 Nov 2017 11:42:10 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 09/23] x86, kaiser: map dynamically-allocated LDTs
Message-ID: <20171123194210.GA2304@zzz.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123003455.275397F7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

> diff -puN arch/x86/kernel/ldt.c~kaiser-user-map-new-ldts arch/x86/kernel/ldt.c
> --- a/arch/x86/kernel/ldt.c~kaiser-user-map-new-ldts	2017-11-22 15:45:49.059619739 -0800
> +++ b/arch/x86/kernel/ldt.c	2017-11-22 15:45:49.062619739 -0800
> @@ -11,6 +11,7 @@
[...]
> +	ret = kaiser_add_mapping((unsigned long)new_ldt->entries, alloc_size,
> +				 __PAGE_KERNEL | _PAGE_GLOBAL);
> +	if (ret) {
> +		__free_ldt_struct(new_ldt);
> +		return NULL;
> +	}
>  	new_ldt->nr_entries = num_entries;
>  	return new_ldt;

__free_ldt_struct() uses new_ldt->nr_entries, so new_ldt->nr_entries needs to be
set earlier.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
