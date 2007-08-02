Date: Wed, 1 Aug 2007 20:56:13 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH] type safe allocator
In-Reply-To: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
Message-ID: <alpine.LFD.0.999.0708012051100.3582@woody.linux-foundation.org>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>


On Wed, 1 Aug 2007, Miklos Szeredi wrote:
>
> I wonder why we don't have type safe object allocators a-la new() in
> C++ or g_new() in glib?
> 
>   fooptr = k_new(struct foo, GFP_KERNEL);

I would object to this if only because of the horrible name.

C++ is not a good language to take ideas from, and "new()" was not it's 
best feature to begin with. "k_new()" is just disgusting.

I'd call it something like "alloc_struct()" instead, which tells you 
exactly what it's all about. Especially since we try to avoid typedefs in 
the kernel, and as a result, it's basically almost always a struct thing.

That said, I'm not at all sure it's worth it. Especially not with all the 
various variations on a theme (zeroed, arrays, etc etc).

Quite frankly, I suspect you would be better off just instrumenting 
"sparse" instead, and matching up the size of the allocation with the type 
it gets assigned to.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
