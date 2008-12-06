Date: Sun, 7 Dec 2008 00:55:36 +1100
From: Nick Andrew <nick@nick-andrew.net>
Subject: Re: [PATCH] Fix incorrect use of loose in migrate.c
Message-ID: <20081206135536.GH5957@mail.local.tull.net>
References: <20081205030807.32309.69191.stgit@marcab.local.tull.net> <20081206121227.GA6292@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081206121227.GA6292@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 06, 2008 at 01:12:27PM +0100, Nick Piggin wrote:
> >  	/*
> >  	 * A dirty page may imply that the underlying filesystem has
> >  	 * the page on some queue. So the page must be clean for
> > -	 * migration. Writeout may mean we loose the lock and the
> > +	 * migration. Writeout may mean we lose the lock and the
> >  	 * page state is no longer what we checked for earlier.
> >  	 * At this point we know that the migration attempt cannot
> >  	 * be successful.
> 
> I don't know... presumably we haven't just gone and lost the little
> bugger. I mean, we were holding it one minute, then... gone?  Do we
> have Alzheimer's? Unlikely. I think we loosed it.

Loosen?

Nick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
