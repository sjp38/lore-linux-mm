In-reply-to: <E1JEPcs-0007V6-Oy@pomaz-ex.szeredi.hu> (message from Miklos
	Szeredi on Mon, 14 Jan 2008 14:45:18 +0100)
Subject: Re: [PATCH 2/2] updating ctime and mtime at syncing
References: <12001991991217-git-send-email-salikhmetov@gmail.com>
	 <12001992023392-git-send-email-salikhmetov@gmail.com>
	 <E1JENAv-0007CM-T9@pomaz-ex.szeredi.hu>
	 <4df4ef0c0801140422l1980d507v1884ad8d8e8bf6d3@mail.gmail.com>
	 <E1JEP9P-0007RD-PP@pomaz-ex.szeredi.hu>  <1200317737.15103.8.camel@twins> <1200317990.15103.11.camel@twins> <E1JEPcs-0007V6-Oy@pomaz-ex.szeredi.hu>
Message-Id: <E1JEPfG-0007Vi-K3@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 14 Jan 2008 14:47:46 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: miklos@szeredi.hu
Cc: peterz@infradead.org, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, protasnb@gmail.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> > More fun, it would require marking them RO but leaving the dirty bit
> > set, because this ext3 fudge where we confuse the page dirty state - or
> > did that get fixed?
> 
> That got fixed by Nick, I think.
> 
> The alternative to marking pages RO, is to walk the PTEs in MS_ASYNC,
> note the dirty bit and mark pages clean.  But it's possibly even more
                              ^^^^
			         ptes, I mean

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
