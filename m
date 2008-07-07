From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
Date: Mon, 7 Jul 2008 20:43:16 +1000
References: <20080625124038.103406301@szeredi.hu> <200807071638.32955.nickpiggin@yahoo.com.au> <E1KFmuc-0001VS-RS@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KFmuc-0001VS-RS@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807072043.16522.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jamie@shareable.org, torvalds@linux-foundation.org, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Monday 07 July 2008 19:21, Miklos Szeredi wrote:
> On Mon, 7 Jul 2008, Nick Piggin wrote:
> > I don't know what became of this thread, but I agree with everyone else
> > you should not skip clearing PG_uptodate here. If nothing else, it
> > weakens some important assertions in the VM. But I agree that splice
> > should really try harder to work with it and we should be a little
> > careful about just changing things like this.
>
> Sure, that's why I rfc'ed.
>
> But I'd still like to know, what *are* those assumptions in the VM
> that would be weakened by this?

Not assumptions (that I know of, but there could be some) but
assertions. For example we assert that pages in page tables are
always uptodate. We'd miss warning if we had an invalidated page
in the pagetables after this change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
