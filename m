In-reply-to: <20070801092909.GN3972@stusta.de> (message from Adrian Bunk on
	Wed, 1 Aug 2007 11:29:09 +0200)
Subject: Re: [RFC PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu> <20070801092909.GN3972@stusta.de>
Message-Id: <E1IGAiD-0006Qf-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 01 Aug 2007 11:41:49 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bunk@stusta.de
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> > I wonder why we don't have type safe object allocators a-la new() in
> > C++ or g_new() in glib?
> > 
> >   fooptr = k_new(struct foo, GFP_KERNEL);
> > 
> > is nicer and more descriptive than
> > 
> >   fooptr = kmalloc(sizeof(*fooptr), GFP_KERNEL);
> >...
> 
> But it's much more likely to break when someone converts fooptr to a 
> different struct.
> 
> It might not be a common case but it sometimes happens - and your type 
> safe variant introduces the possibility for really nasty bugs.

The compiler would emit a warning about assigning to a pointer of
different type.  That's a fairly strong hint that something just
broke.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
