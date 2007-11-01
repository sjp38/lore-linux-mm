In-reply-to: <1193936949.27652.321.camel@twins> (message from Peter Zijlstra
	on Thu, 01 Nov 2007 18:09:09 +0100)
Subject: Re: per-bdi-throttling: synchronous writepage doesn't work
	correctly
References: <E1IndEw-00046x-00@dorka.pomaz.szeredi.hu>
	 <1193935886.27652.313.camel@twins>
	 <E1IndPT-00047e-00@dorka.pomaz.szeredi.hu> <1193936949.27652.321.camel@twins>
Message-Id: <E1Indqb-00049a-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 01 Nov 2007 18:28:49 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: jdike@addtoit.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> The page not having PG_writeback set on return is a hint, but not fool
> proof, it could be the device is just blazing fast.

Hmm, does it actually has to be foolproof though?  What will happen if
bdi_writeout_inc() is called twice for the page?  The device will get
twice the number of pages it deserves?  That's not all that bad,
especially since that is a really really fast device.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
