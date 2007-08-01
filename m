In-reply-to: <p73myxbpm8r.fsf@bingen.suse.de> (message from Andi Kleen on 01
	Aug 2007 12:44:52 +0200)
Subject: Re: [RFC PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu> <p73myxbpm8r.fsf@bingen.suse.de>
Message-Id: <E1IGAx0-0006TK-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 01 Aug 2007 11:57:06 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andi@firstfloor.org
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
> > 
> > and more safe than
> > 
> >   fooptr = kmalloc(sizeof(struct foo), GFP_KERNEL);
> 
> How is it more safe? It seems 100% equivalent to me,
> just a different syntax.

Note the (type *) cast:

#define k_new(type, flags) ((type *) kmalloc(sizeof(type), flags))

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
