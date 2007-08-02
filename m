In-reply-to: <alpine.LFD.0.999.0708021302500.8258@enigma.security.iitk.ac.in>
	(message from Satyam Sharma on Thu, 2 Aug 2007 13:07:47 +0530 (IST))
Subject: Re: [RFC PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu> <alpine.LFD.0.999.0708021302500.8258@enigma.security.iitk.ac.in>
Message-Id: <E1IGVIO-0000tT-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 02 Aug 2007 09:40:32 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: satyam@infradead.org
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> >  
> > +/**
> > + * k_new - allocate given type object
> > + * @type: the type of the object to allocate
> > + * @flags: the type of memory to allocate.
> > + */
> > +#define k_new(type, flags) ((type *) kmalloc(sizeof(type), flags))
> 
> What others already said, plus:
> 
> kmalloc()'ing sizeof(struct foo) is not always what we want in C either.
> 
> Several kernel structs have zero-length / variable-length array members
> and space must be allocated for them only at alloc() time ... would be
> impossible to make them work with this scheme.

Exactly.  We can, and should use kmalloc() for that.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
