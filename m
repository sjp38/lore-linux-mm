In-reply-to: <20081022125140.GB826@shareable.org> (message from Jamie Lokier
	on Wed, 22 Oct 2008 13:51:40 +0100)
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <E1KsIHV-0006JW-65@pomaz-ex.szeredi.hu> <20081021150948.GB28279@fogou.chygwyn.com> <E1KsJr2-0006jT-1R@pomaz-ex.szeredi.hu> <20081022125140.GB826@shareable.org>
Message-Id: <E1KseOO-0001HK-Rq@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 22 Oct 2008 16:08:56 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jamie@shareable.org
Cc: miklos@szeredi.hu, steve@chygwyn.com, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008, Jamie Lokier wrote:
> So GFS goes to great lengths to ensure that read/write are coherent,
> so are mmaps (writable or not), but _splice_ is not coherent in the
> sense that it can send invalid but non-random data? :-)

Spice is not coherent in any sense on any filesystem :)

Your idea about COWing the page would be nice, and I think it may even
be implementable.  Currently the biggest problem with splice is the
lack of users, we'd have to solve that first somehow.

> Also, is there still a problem where the data is "valid" but part of
> the page may have been zero'd by truncate, which is then transmitted
> by splice?

Yes.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
