Date: Wed, 2 May 2007 00:02:49 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
	(-1)
Message-ID: <20070502070249.GA7018@suse.de>
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org> <46338AEB.2070109@imap.cc> <20070428141024.887342bd.akpm@linux-foundation.org> <4636248E.7030309@imap.cc> <20070430112130.b64321d3.akpm@linux-foundation.org> <46364346.6030407@imap.cc> <20070430124638.10611058.akpm@linux-foundation.org> <46383742.9050503@imap.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46383742.9050503@imap.cc>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tilman Schmidt <tilman@imap.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, kay.sievers@vrfy.org
List-ID: <linux-mm.kvack.org>

On Wed, May 02, 2007 at 09:01:22AM +0200, Tilman Schmidt wrote:
> Am 30.04.2007 21:46 schrieb Andrew Morton:
> > Not really - everything's tangled up.  A bisection search on the
> > 2.6.21-rc7-mm2 driver tree would be the best bet.
> 
> And the winner is:
> 
> gregkh-driver-driver-core-make-uevent-environment-available-in-uevent-file.patch
> 
> Reverting only that from 2.6.21-rc7-mm2 gives me a working kernel
> again.
> 
> I'll try building 2.6.21-git3 minus that one next, but I'll have
> to revert it manually, because my naive attempt to "patch -R" it
> failed 1 out of 2 hunks.

Ok, that's just wierd, it only adds a new feature, it doesn't touch any
existing code to cause things to go wrong.

Can you try using 'git bisect' on Linus's tree instead?  That should
show the real problem much easier.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
