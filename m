In-reply-to: <p73643zpjy8.fsf@bingen.suse.de> (message from Andi Kleen on 01
	Aug 2007 13:34:23 +0200)
Subject: Re: [RFC PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
	<p73myxbpm8r.fsf@bingen.suse.de>
	<E1IGAx0-0006TK-00@dorka.pomaz.szeredi.hu> <p73643zpjy8.fsf@bingen.suse.de>
Message-Id: <E1IGBiG-0006fv-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 01 Aug 2007 12:45:56 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andi@firstfloor.org
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> > 
> > #define k_new(type, flags) ((type *) kmalloc(sizeof(type), flags))
> 
> The cast doesn't make it more safe in any way

I does, since a warning will be issued, if the type of the assigned
pointer doesn't match the requested allocation.

And yes, warnings are _very_ useful in C for enforcing type safety.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
