From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
Date: Tue, 8 Jul 2008 12:22:07 +1000
References: <20080625124038.103406301@szeredi.hu> <200807080028.00642.nickpiggin@yahoo.com.au> <E1KFsKI-0002IN-ES@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KFsKI-0002IN-ES@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807081222.07633.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jamie@shareable.org, torvalds@linux-foundation.org, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tuesday 08 July 2008 01:08, Miklos Szeredi wrote:
> On Tue, 8 Jul 2008, Nick Piggin wrote:

> > > Well, other than my original proposal, which would just have reused
> > > the do_generic_file_read() infrastructure for splice.  I still don't
> > > see why we shouldn't use that, until the whole async splice-in thing
> > > is properly figured out.
> >
> > Given the alternatives, perhaps this is for the best, at least for
> > now.
>
> Yeah.  I'm not at all opposed to improving splice to be able to do all
> sorts of fancy things like async splice-in, and stealing of pages.
> But it's unlikely that I will have the motivation to implement any of
> them just to fix this bug.

Yeah. Well then, would you mind having another cut at the patch to
do that? I guess it might help if you don't remove the ->confirm
code -- after fixing the bug then we could discuss what to do with
that code and how we could implement async.

I guess it would be nice to find something that gets a lot of
benefit with the async splicing. Luckily the existing scheme is
workable enough that it would be easy to test a hunch just by
patching it back in...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
