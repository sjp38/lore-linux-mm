In-reply-to: <20080731001131.GA30900@shareable.org> (message from Jamie Lokier
	on Thu, 31 Jul 2008 01:11:31 +0100)
Subject: Re: [patch v3] splice: fix race with page invalidation
References: <20080731001131.GA30900@shareable.org>
Message-Id: <E1KOSbz-0007b6-0L@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 31 Jul 2008 09:30:11 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jamie@shareable.org
Cc: miklos@szeredi.hu, torvalds@linux-foundation.org, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jul 2008, Jamie Lokier wrote:
> I'm more concerned by sendfile() users like Apache, Samba, FTPd.  In
> an earlier thread on this topic, I asked if the splice bug can also
> result in sendfile() sending blocks of zeros, when a file is truncated
> after it has been sent, and the answer was yes probably.
> 
> Not that I checked or anything.  But if it affects sendfile() it's a
> bigger deal - that has many users.

Nick also pointed out, that it also affects plain read(2), albeit only
with a tiny window.

But partial truncates are _rare_ (we don't even have a UNIX utility
for that ;), so in practice all this may not actually matter very
much.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
