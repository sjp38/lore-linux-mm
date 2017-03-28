Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99EA36B0397
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:13:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p64so47101411wrb.18
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 23:13:03 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id m190si2190486wme.2.2017.03.27.23.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 23:13:02 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id w43so16479929wrb.1
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 23:13:02 -0700 (PDT)
Date: Tue, 28 Mar 2017 08:12:59 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 6/8] x86/dump_pagetables: Add support 5-level paging
Message-ID: <20170328061259.GC20135@gmail.com>
References: <20170327162925.16092-1-kirill.shutemov@linux.intel.com>
 <20170327162925.16092-7-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170327162925.16092-7-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> +#if PTRS_PER_P4D > 1
> +
> +static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
> +							unsigned long P)

Pretty ugly line break. Either don't break the line, or break it in a more logical 
place, like:

static void
walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr, unsigned long P)

> +	start = (p4d_t *) pgd_page_vaddr(addr);

The space between the type cast and the function invocation is not needed.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
