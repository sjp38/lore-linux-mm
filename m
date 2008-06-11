From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.26-rc5-mm2
Date: Thu, 12 Jun 2008 09:58:38 +1000
References: <20080609223145.5c9a2878.akpm@linux-foundation.org> <200806101848.22237.nickpiggin@yahoo.com.au> <20080611140902.544e59ec@bree.surriel.com>
In-Reply-To: <20080611140902.544e59ec@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806120958.38545.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 12 June 2008 04:09, Rik van Riel wrote:
> On Tue, 10 Jun 2008 18:48:21 +1000
>
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > > > The tmpfs PageSwapBacked stuff seems rather broken. For
> > > > them write_begin/write_end path, it is filemap.c, not shmem.c,
> > > > which allocates the page, so its no wonder it goes bug. Will
> > > > try to do more testing without shmem.
>
> Fun, so what does shmem_alloc_page do?
>
> > > rikstuff.  Could be that the merge caused a problem?
> >
> > Doesn't look like it, but I hadn't followed the changes too closely:
> > rather they just need to test loopback over tmpfs.
>
> Does loopback over tmpfs use a different allocation path?

I'm sorry, hmm I didn't look closely enough and forgot that
write_begin/write_end requires the callee to allocate the page
as well, and that Hugh had nicely unified most of that.

So maybe it's not that. It's pretty easy to hit I found with
ext2 mounted over loopback on a tmpfs file.


> > Is the plan to merge all reclaim changes in a big hit, rather than
> > slowly trickle in the different independent changes?
>
> My original plan was to merge them incrementally, but Andrew is
> right that we should give the whole set as much testing as
> possible.
>
> I have done all the cleanups Andrew asked and fixed the bugs
> that I found after that merge/cleanup.  Your bug is the one
> I still need to fix before giving Andrew a whole new set of
> split LRU patches to merge.
>
> (afterwards, I will go incremental fixes only - the cleanups
> he asked for were just too big to do as incrementals)

OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
