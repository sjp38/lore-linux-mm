From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc patch 2/4] splice: remove steal from pipe_buf_operations
Date: Tue, 24 Jun 2008 22:21:34 +1000
References: <20080621154607.154640724@szeredi.hu> <20080624080152.GI20851@kernel.dk> <E1KB4EV-0000u3-5j@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KB4EV-0000u3-5j@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806242221.35304.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tuesday 24 June 2008 18:50, Miklos Szeredi wrote:
> > On Sat, Jun 21 2008, Miklos Szeredi wrote:
> > > From: Miklos Szeredi <mszeredi@suse.cz>
> > >
> > > The 'steal' operation hasn't been used for some time.  Remove it and
> > > the associated dead code.  If it's needed in the future, it can always
> > > be easily restored.
> >
> > I'd rather not just remove this, it's basically waiting for Nick to make
> > good on his promise to make stealing work again (he disabled it).
>
> Yes, I read the commit log.  He disabled it with the intent that we
> may or may not want this interface back, and possibly in some other
> form.
>
> Jens, does somebody need this feature?  What for?  If not, then I
> guess nobody will bother implementing it.
>
> (Nick CC-d)

I've kind of wanted to implement it "because it is cool", but also
because I hoped to ensure the new write_begin/write_end APIs would
be general enough to support it.

Unfortunately I'm not aware of a killer feature so it's kept going
down the todo pile. However it really is one of those things where
you need the API to work before you get programs emerging that make
interesting uses out of it. I think if it can be done without adding
complication to pagecache/filesystem code, then it would be nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
