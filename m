Date: Wed, 1 Aug 2007 13:44:13 +0200 (CEST)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [RFC PATCH] type safe allocator
In-Reply-To: <E1IGBiG-0006fv-00@dorka.pomaz.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0708011341160.26668@fbirervta.pbzchgretzou.qr>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu> <p73myxbpm8r.fsf@bingen.suse.de>
 <E1IGAx0-0006TK-00@dorka.pomaz.szeredi.hu> <p73643zpjy8.fsf@bingen.suse.de>
 <E1IGBiG-0006fv-00@dorka.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: andi@firstfloor.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Aug 1 2007 12:45, Miklos Szeredi wrote:
>> > 
>> > #define k_new(type, flags) ((type *) kmalloc(sizeof(type), flags))
>> 
>> The cast doesn't make it more safe in any way
>
>I does, since a warning will be issued, if the type of the assigned
>pointer doesn't match the requested allocation.
>
>And yes, warnings are _very_ useful in C for enforcing type safety.

	void *p;
	p = (struct foo *)kmalloc(sizeof(struct foo), GFP_KERNEL);



	Jan
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
