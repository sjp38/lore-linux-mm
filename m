Date: Thu, 2 Aug 2007 15:35:56 +0200 (CEST)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] type safe allocator
In-Reply-To: <E1IGaOE-0001a3-00@dorka.pomaz.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0708021534050.24572@fbirervta.pbzchgretzou.qr>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
 <E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu> <b6fcc0a0708020504j7588061fq7e70a50499dcbdfe@mail.gmail.com>
 <Pine.LNX.4.64.0708021417400.24572@fbirervta.pbzchgretzou.qr>
 <E1IGaOE-0001a3-00@dorka.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: adobriyan@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Aug 2 2007 15:06, Miklos Szeredi wrote:
>> On Aug 2 2007 16:04, Alexey Dobriyan wrote:
>> >On 8/2/07, Miklos Szeredi <miklos@szeredi.hu> wrote:
>> >>   fooptr = kmalloc(sizeof(struct foo), ...);
>> >
>> >Key word is "traditional". Good traditional form which even half-competent
>> >C programmers immediately parse in retina.
>> 
>> And being aware of the potential type-unsafety makes programmers more
>> careful IMHO.
>
>That's a _really_ good reason ;)

Yes, a good reason not to use g_new(), so people do get bitten when
they are doingitwrong.



	Jan
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
