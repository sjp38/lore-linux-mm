Date: Thu, 7 Jun 2007 13:12:12 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC/PATCH v2] shmem: use lib/parser for mount options
Message-Id: <20070607131212.6d187fdd.randy.dunlap@oracle.com>
In-Reply-To: <Pine.LNX.4.64.0706071940340.32729@blonde.wat.veritas.com>
References: <20070524000044.b62a0792.randy.dunlap@oracle.com>
	<20070605153532.7b88e529.randy.dunlap@oracle.com>
	<Pine.LNX.4.64.0706071940340.32729@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007 19:57:18 +0100 (BST) Hugh Dickins wrote:

> On Tue, 5 Jun 2007, Randy Dunlap wrote:
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > 
> > Convert shmem (tmpfs) to use the in-kernel mount options parsing library.
> > 
> > Old size: 0x368 = 872 bytes
> > New size: 0x3b6 = 950 bytes
> 
> Varies with arch/config: in some cases the old is smaller,
> in other cases your new.  And you're not accounting for (nor
> drawing attention to) any bugfixes you added (nor, for that matter,
> on any bugs you added - but we usually keep quiet about those ;)
> 
> > If you feel that there is no significant advantage to this, that's OK,
> > I can just drop it.
> 
> Hmm.  Hmm.  My own personal feeling is that it's not really an
> improvement; especially the Opt_mpol block (and the unnecessary
> is_remount arg I already commented on).

Yes, I reread that comment earlier today.

The mpol=args parameter string is messy, due to the commas that
may be in it, whereas the old & new parsers like to split options
at commas.


> But I'm familiar with what's already there: I'd happily be overruled
> on this if others feel yours really is an improvement.  Anyone? 
> And you've cleaned up that "no space after comma" coding style.
>  	 
> For me, the main question is, did you fix any bugs?  You certainly
> discovered the nonline mpol crash, which was worthwhile in itself.
> And you've discovered that memparse accepts k, M, G without a digit:
> if it treated that as 1 I wouldn't mind so much, but it treats it as 0.

Right.  memparse could be fixed, or lib/parser.c could gain some
additions/extensions, such as support for memparse and long long
option values.  I think that those would be useful additions.

> We can live with that; but if we're to fix it, I'd prefer the fix to
> go into memparse itself - though it's called from many places, so
> maybe there's an audit job to see if the present behaviour could
> make sense in any of them.
> 
> Hugh

I can't convince myself that it's worth the change...  :)

Thanks for looking.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
