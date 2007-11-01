In-reply-to: <1193942132.27652.331.camel@twins> (message from Peter Zijlstra
	on Thu, 01 Nov 2007 19:35:32 +0100)
Subject: Re: per-bdi-throttling: synchronous writepage doesn't work
	correctly
References: <E1IndEw-00046x-00@dorka.pomaz.szeredi.hu>
	 <1193935886.27652.313.camel@twins>
	 <E1IndPT-00047e-00@dorka.pomaz.szeredi.hu>
	 <1193936949.27652.321.camel@twins>  <1193937408.27652.326.camel@twins> <1193942132.27652.331.camel@twins>
Message-Id: <E1InfZx-0004Eu-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 01 Nov 2007 20:19:45 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: peterz@infradead.org
Cc: jdike@addtoit.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

> > 
> >       See the file "Locking" for more details.
> > 
> > 
> > The "should set PG_Writeback" bit threw me off I guess.
> 
> Hmm, set_page_writeback() is also the one clearing the radix tree dirty
> tag. So if that is not called, we get in a bit of a mess, no?
> 
> Which makes me think hostfs is buggy.

Yes, looks like that sort of usage is not valid.  But not clearing the
dirty tag won't cause any malfunction, it'll just waste some CPU when
looking for dirty pages to write back.  This is probably why this
wasn't noticed earlier.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
