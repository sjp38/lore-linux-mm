In-reply-to: <Pine.LNX.4.64.0708021534050.24572@fbirervta.pbzchgretzou.qr>
	(message from Jan Engelhardt on Thu, 2 Aug 2007 15:35:56 +0200 (CEST))
Subject: Re: [PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
 <E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu> <b6fcc0a0708020504j7588061fq7e70a50499dcbdfe@mail.gmail.com>
 <Pine.LNX.4.64.0708021417400.24572@fbirervta.pbzchgretzou.qr>
 <E1IGaOE-0001a3-00@dorka.pomaz.szeredi.hu> <Pine.LNX.4.64.0708021534050.24572@fbirervta.pbzchgretzou.qr>
Message-Id: <E1IGb3I-0001js-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 02 Aug 2007 15:49:20 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jengelh@computergmbh.de
Cc: miklos@szeredi.hu, adobriyan@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> >> On Aug 2 2007 16:04, Alexey Dobriyan wrote:
> >> >On 8/2/07, Miklos Szeredi <miklos@szeredi.hu> wrote:
> >> >>   fooptr = kmalloc(sizeof(struct foo), ...);
> >> >
> >> >Key word is "traditional". Good traditional form which even half-competent
> >> >C programmers immediately parse in retina.
> >> 
> >> And being aware of the potential type-unsafety makes programmers more
> >> careful IMHO.
> >
> >That's a _really_ good reason ;)
> 
> Yes, a good reason not to use g_new(), so people do get bitten when
> they are doingitwrong.

Should we turn off all warnings then, to make people more careful
after constantly being bitten by stupid mistakes?

That's one way to think of it, yes.  But I think most would agree,
that we have better things to do than being careful about things that
the compiler can check for us.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
