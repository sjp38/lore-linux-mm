In-reply-to: <20081021125915.GA26697@fogou.chygwyn.com> (steve@chygwyn.com)
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com>
Message-Id: <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 21 Oct 2008 15:14:48 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: steve@chygwyn.com
Cc: miklos@szeredi.hu, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008, steve@chygwyn.com
> > Is there a case where retrying in case of !PageUptodate() makes any
> > sense?
> >
> Yes... cluster filesystems. Its very important in case a readpage
> races with a lock demotion. Since the introduction of page_mkwrite
> that hasn't worked quite right, but by retrying when the page is
> not uptodate, that should fix the problem,

I see.

Could you please give some more details?  In particular I don't know
what's lock demotion in this context.  And how page_mkwrite() come
into the picture?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
