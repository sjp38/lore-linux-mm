Received: by nz-out-0102.google.com with SMTP id v1so342523nzb
        for <linux-mm@kvack.org>; Fri, 21 Apr 2006 01:57:32 -0700 (PDT)
Message-ID: <84144f020604210157s406a08a7yd3c43d9ef2939ce@mail.gmail.com>
Date: Fri, 21 Apr 2006 11:57:32 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch] mm: introduce remap_vmalloc_range (pls. drop previous patchset)
In-Reply-To: <20060421084503.GS21660@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060421084503.GS21660@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On 4/21/06, Nick Piggin <npiggin@suse.de> wrote:
> +       addr = (void *)((unsigned long)addr + (pgoff << PAGE_SHIFT));

As Andrew said, you can get rid of the casting with:

  addr += pgoff << PAGE_SHIFT;

> +       do {
> +               struct page *page = vmalloc_to_page(addr);
> +               ret = vm_insert_page(vma, uaddr, page);
> +               if (ret)
> +                       return ret;
> +
> +               uaddr += PAGE_SIZE;
> +               addr = (void *)((unsigned long)addr+PAGE_SIZE);

Same here.

                                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
