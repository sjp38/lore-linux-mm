In-reply-to: <20080624080152.GI20851@kernel.dk> (message from Jens Axboe on
	Tue, 24 Jun 2008 10:01:54 +0200)
Subject: Re: [rfc patch 2/4] splice: remove steal from pipe_buf_operations
References: <20080621154607.154640724@szeredi.hu> <20080621154724.203822363@szeredi.hu> <20080624080152.GI20851@kernel.dk>
Message-Id: <E1KB4EV-0000u3-5j@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 24 Jun 2008 10:50:35 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: miklos@szeredi.hu, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

> On Sat, Jun 21 2008, Miklos Szeredi wrote:
> > From: Miklos Szeredi <mszeredi@suse.cz>
> > 
> > The 'steal' operation hasn't been used for some time.  Remove it and
> > the associated dead code.  If it's needed in the future, it can always
> > be easily restored.
> 
> I'd rather not just remove this, it's basically waiting for Nick to make
> good on his promise to make stealing work again (he disabled it).

Yes, I read the commit log.  He disabled it with the intent that we
may or may not want this interface back, and possibly in some other
form.

Jens, does somebody need this feature?  What for?  If not, then I
guess nobody will bother implementing it.

(Nick CC-d)

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
