Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA7E6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 10:39:49 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 17so5932555wrm.10
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 07:39:49 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t23sor5441973edb.49.2018.01.29.07.39.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jan 2018 07:39:47 -0800 (PST)
Date: Mon, 29 Jan 2018 18:39:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv7 5/4] x86/boot/compressed/64: Support switching from 5-
 to 4-level paging
Message-ID: <20180129153945.sme6f2zx3fpj24qy@node.shutemov.name>
References: <20180129115351.85224-1-kirill.shutemov@linux.intel.com>
 <20180129150758.81016-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129150758.81016-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 29, 2018 at 06:07:58PM +0300, Kirill A. Shutemov wrote:
> +	/*
> +	 * We are in 5-level paging mode, but we want to switch to 4-level.
> +	 * Let's take the first entry in the top-level page table as our new CR3.
> +	 */
> +	movl	%cr3, %eax
> +	movl	(%eax), %eax
> +	movl	%eax, %cr3

Aghh.. Please ignore this.

It would fail if CR3 points above 4G.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
