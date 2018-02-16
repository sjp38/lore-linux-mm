Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 87E696B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 09:11:21 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id z11so2255174plo.21
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 06:11:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p125si1615049pfb.241.2018.02.16.06.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Feb 2018 06:11:20 -0800 (PST)
Date: Fri, 16 Feb 2018 06:11:10 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/3] x86/xen: Allow XEN_PV and XEN_PVH to be enabled with
 X86_5LEVEL
Message-ID: <20180216141110.GA10501@bombadil.infradead.org>
References: <20180216114948.68868-1-kirill.shutemov@linux.intel.com>
 <20180216114948.68868-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180216114948.68868-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 16, 2018 at 02:49:46PM +0300, Kirill A. Shutemov wrote:
> @@ -38,12 +38,12 @@
>   *
>   */
>  
> +#define l4_index(x)	(((x) >> 39) & 511)
>  #define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))

Shouldn't that be
+#define p4d_index(x)	(((x) >> P4D_SHIFT) & (PTRS_PER_P4D-1))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
