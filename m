Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DE1896B00B4
	for <linux-mm@kvack.org>; Sun,  8 Mar 2009 22:22:10 -0400 (EDT)
Message-ID: <49B47D50.5000608@cn.fujitsu.com>
Date: Mon, 09 Mar 2009 10:22:08 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v2] memdup_user(): introduce
References: <49B0CAEC.80801@cn.fujitsu.com>	<20090306082056.GB3450@x200.localdomain>	<49B0DE89.9000401@cn.fujitsu.com>	<20090306003900.a031a914.akpm@linux-foundation.org>	<49B0E67C.2090404@cn.fujitsu.com>	<20090306011548.ffdf9cbc.akpm@linux-foundation.org>	<49B0F1B9.1080903@cn.fujitsu.com>	<20090306150335.c512c1b6.akpm@linux-foundation.org> <20090307084805.7cf3d574@infradead.org>
In-Reply-To: <20090307084805.7cf3d574@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, adobriyan@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>> +EXPORT_SYMBOL(memdup_user);
> 
> Hi,
> 
> I like the general idea of this a lot; it will make things much less
> error prone (and we can add some sanity checks on "len" to catch the
> standard security holes around copy_from_user usage). I'd even also
> want a memdup_array() like thing in the style of calloc().
> 
> However, I have two questions/suggestions for improvement:
> 
> I would like to question the use of the gfp argument here;
> copy_from_user sleeps, so you can't use GFP_ATOMIC anyway.
> You can't use GFP_NOFS etc, because the pagefault path will happily do
> things that are equivalent, if not identical, to GFP_KERNEL.
> 
> So the only value you can pass in correctly, as far as I can see, is
> GFP_KERNEL. Am I wrong?
> 

Right! I just dug and found a few kmalloc(GFP_ATOMIC/GFP_NOFS)+copy_from_user(),
so we have one more reason to use this memdup_user().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
