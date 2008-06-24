In-reply-to: <20080624111913.GP20851@kernel.dk> (message from Jens Axboe on
	Tue, 24 Jun 2008 13:19:13 +0200)
Subject: Re: [rfc patch 3/4] splice: remove confirm from pipe_buf_operations
References: <20080621154607.154640724@szeredi.hu> <20080621154726.494538562@szeredi.hu> <20080624080440.GJ20851@kernel.dk> <E1KB4Id-0000un-PV@pomaz-ex.szeredi.hu> <20080624111913.GP20851@kernel.dk>
Message-Id: <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 24 Jun 2008 13:36:35 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: miklos@szeredi.hu, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> It's an unfortunate side effect of the read-ahead, I'd much rather just
> get rid of that. It _should_ behave like the non-ra case, when a page is
> added it merely has IO started on it. So we want to have that be
> something like
> 
>         if (!PageUptodate(page) && !PageInFlight(page))
>                 ...
> 
> basically like PageWriteback(), but for read-in.

OK it could be done, possibly at great pain.  But why is it important?
What's the use case where it matters that splice-in should not block
on the read?

And note, after the pipe is full it will block no matter what, since
the consumer will have to wait until the page is brought uptodate, and
can only then commence with getting the data out from the pipe.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
