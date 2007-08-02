Subject: Re: [PATCH] type safe allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <b6fcc0a0708020504j7588061fq7e70a50499dcbdfe@mail.gmail.com>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
	 <E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu>
	 <b6fcc0a0708020504j7588061fq7e70a50499dcbdfe@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 15:47:56 +0200
Message-Id: <1186062476.12034.115.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-02 at 16:04 +0400, Alexey Dobriyan wrote:
> On 8/2/07, Miklos Szeredi <miklos@szeredi.hu> wrote:
> > The linux kernel doesn't have a type safe object allocator a-la new()
> > in C++ or g_new() in glib.
> >
> > Introduce two helpers for this purpose:
> >
> >    alloc_struct(type, gfp_flags);
> >
> >    zalloc_struct(type, gfp_flags);
> 
> ick.
> 
> > These macros take a type name (usually a 'struct foo') as first
> > argument
> 
> So one has to type struct twice.

thrice in some cases like alloc_struct(struct task_struct, GFP_KERNEL)

I've always found this _struct postfix a little daft, perhaps its time
to let the janitors clean that out?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
