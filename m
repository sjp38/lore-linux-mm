Date: Wed, 27 Oct 2004 14:29:14 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Re: news about IDE PIO HIGHMEM bug (was: Re: 2.6.9-mm1)
Message-Id: <20041027142914.197c72ed.akpm@osdl.org>
In-Reply-To: <417FCE4E.4080605@pobox.com>
References: <58cb370e041027074676750027@mail.gmail.com>
	<417FBB6D.90401@pobox.com>
	<1246230000.1098892359@[10.10.2.4]>
	<1246750000.1098892883@[10.10.2.4]>
	<417FCE4E.4080605@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@pobox.com>
Cc: mbligh@aracnet.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bzolnier@gmail.com, rddunlap@osdl.org, wli@holomorphy.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> > However, pfn_to_page(page_to_pfn(page) + 1) might be safer. If rather slower.
> 
> 
> Is this patch acceptable to everyone?  Andrew?

spose so.  The scatterlist API is being a bit silly there.

It might be worthwhile doing:

#ifdef CONFIG_DISCONTIGMEM
#define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + n)
#else
#define nth_page(page,n) ((page)+(n))
#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
