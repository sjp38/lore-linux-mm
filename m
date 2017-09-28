Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 419816B0261
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:32:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r74so349669wme.20
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:32:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l101sor380315wrc.16.2017.09.28.01.31.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:31:58 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:31:55 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 12/19] x86/mm: Adjust virtual address space layout in
 early boot.
Message-ID: <20170928083155.7qahecaeifz5em5f@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-13-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-13-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> We need to adjust virtual address space to support switching between
> paging modes.
> 
> The adjustment happens in __startup_64().

> +#ifdef CONFIG_X86_5LEVEL
> +	if (__read_cr4() & X86_CR4_LA57) {
> +		pgtable_l5_enabled = 1;
> +		pgdir_shift = 48;
> +		ptrs_per_p4d = 512;
> +	}
> +#endif

So CR4 really sucks as a parameter passing interface - was it us who enabled LA57 
in the early boot code, right? Couldn't we add a flag which gets set there, or 
something?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
