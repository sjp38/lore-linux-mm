Date: Tue, 22 Jul 2008 02:37:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Deinline a few functions in mmap.c
Message-Id: <20080722023704.944efd72.akpm@linux-foundation.org>
In-Reply-To: <200807051837.30219.vda.linux@googlemail.com>
References: <200807051837.30219.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Denys Vlasenko <vda.linux@googlemail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 5 Jul 2008 18:37:30 +0200 Denys Vlasenko <vda.linux@googlemail.com> wrote:

> __vma_link_file and expand_downwards functions are not small,
> yeat they are marked inline. They probably had one callsite
> sometime in the past, but now they have more.
> In order to prevent similar thing, I also deinlined
> expand_upwards, despite it having only pne callsite.
> Nowadays gcc auto-inlines such static functions anyway.
> In find_extend_vma, I removed one extra level of indirection.
> 
> Patch is deliberately generated with -U $BIGNUM to make
> it easier to see that functions are big.
> 
> Result:
> 
> # size */*/mmap.o */vmlinux
>    text    data     bss     dec     hex filename
>    9514     188      16    9718    25f6 0.org/mm/mmap.o
>    9237     188      16    9441    24e1 deinline/mm/mmap.o
> 6124402  858996  389480 7372878  70804e 0.org/vmlinux
> 6124113  858996  389480 7372589  707f2d deinline/vmlinux
> 

So I left this so long that the patch doesn't vaguely apply any more on
-mm, at least.  The large amounts of context didn't help.

I had a go at fixing it, but I can't even compile test it because this
morning's linux-next pull was a complete wreck.  Maybe tomorrow...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
