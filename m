Date: Thu, 2 Aug 2007 14:24:44 +0200 (CEST)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] type safe allocator
In-Reply-To: <b6fcc0a0708020504j7588061fq7e70a50499dcbdfe@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0708021417400.24572@fbirervta.pbzchgretzou.qr>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
 <E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu> <b6fcc0a0708020504j7588061fq7e70a50499dcbdfe@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Aug 2 2007 16:04, Alexey Dobriyan wrote:
>On 8/2/07, Miklos Szeredi <miklos@szeredi.hu> wrote:
>>   fooptr = kmalloc(sizeof(struct foo), ...);
>
>Key word is "traditional". Good traditional form which even half-competent
>C programmers immediately parse in retina.

And being aware of the potential type-unsafety makes programmers more
careful IMHO.

>
>> +/**
>> + * alloc_struct - allocate given type object
>> + * @type: the type of the object to allocate
>> + * @flags: the type of memory to allocate.
>> + */
>> +#define alloc_struct(type, flags) ((type *) kmalloc(sizeof(type), flags))

>someone will write alloc_struct(int, GFP_KERNEL), I promise.

and someone else will write

	struct complexthing foo;
	alloc_struct(foo, GFP_KERNEL);



	Jan
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
