From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch v3] splice: fix race with page invalidation
Date: Sat, 2 Aug 2008 14:26:50 +1000
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <200808011122.51792.nickpiggin@yahoo.com.au> <E1KOzMt-0003fa-Ah@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KOzMt-0003fa-Ah@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808021426.50436.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: torvalds@linux-foundation.org, jens.axboe@oracle.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 02 August 2008 04:28, Miklos Szeredi wrote:
> On Fri, 1 Aug 2008, Nick Piggin wrote:
> > Well, a) it probably makes sense in that case to provide another mode
> > of operation which fills the data synchronously from the sender and
> > copys it to the pipe (although the sender might just use read/write)
> > And b) we could *also* look at clearing PG_uptodate as an optimisation
> > iff that is found to help.
>
> IMO it's not worth it to complicate the API just for the sake of
> correctness in the so-very-rare read error case.  Users of the splice
> API will simply ignore this requirement, because things will work fine
> on ext3 and friends, and will break only rarely on NFS and FUSE.
>
> So I think it's much better to make the API simple: invalid pages are
> OK, and for I/O errors we return -EIO on the pipe.  It's not 100%
> correct, but all in all it will result in less buggy programs.

That's true, but I hate how we always (in the VM, at least) just brush
error handling under the carpet because it is too hard :(

I guess your patch is OK, though. I don't see any reasons it could cause
problems...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
