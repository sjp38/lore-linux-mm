In-reply-to: <Pine.LNX.4.64.0708011341160.26668@fbirervta.pbzchgretzou.qr>
	(message from Jan Engelhardt on Wed, 1 Aug 2007 13:44:13 +0200 (CEST))
Subject: Re: [RFC PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu> <p73myxbpm8r.fsf@bingen.suse.de>
 <E1IGAx0-0006TK-00@dorka.pomaz.szeredi.hu> <p73643zpjy8.fsf@bingen.suse.de>
 <E1IGBiG-0006fv-00@dorka.pomaz.szeredi.hu> <Pine.LNX.4.64.0708011341160.26668@fbirervta.pbzchgretzou.qr>
Message-Id: <E1IGCoQ-0006q9-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 01 Aug 2007 13:56:22 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jengelh@computergmbh.de
Cc: miklos@szeredi.hu, andi@firstfloor.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> >> > 
> >> > #define k_new(type, flags) ((type *) kmalloc(sizeof(type), flags))
> >> 
> >> The cast doesn't make it more safe in any way
> >
> >I does, since a warning will be issued, if the type of the assigned
> >pointer doesn't match the requested allocation.
> >
> >And yes, warnings are _very_ useful in C for enforcing type safety.
> 
> 	void *p;
> 	p = (struct foo *)kmalloc(sizeof(struct foo), GFP_KERNEL);

Using void pointers is _obviously_ not type safe.  What has that got
to do with k_new()?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
