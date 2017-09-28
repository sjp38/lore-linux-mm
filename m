Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CBB6B6B025F
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:21:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id z203so331580wmc.18
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:21:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c10sor350265wrc.60.2017.09.28.01.21.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:21:40 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:21:38 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 08/19] x86/mm: Make PGDIR_SHIFT and PTRS_PER_P4D
 variable
Message-ID: <20170928082138.ayuwbf6jhy6yyqu4@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-9-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-9-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

>  #define P4D_SHIFT	39
> -#define PTRS_PER_P4D	512
> +#define __PTRS_PER_P4D	512
> +#define PTRS_PER_P4D	ptrs_per_p4d
>  #define P4D_SIZE	(_AC(1, UL) << P4D_SHIFT)
>  #define P4D_MASK	(~(P4D_SIZE - 1))

PTRS_PER_P4D_MAX would be a better name than random underscores ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
