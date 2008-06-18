Date: Wed, 18 Jun 2008 15:52:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] migration_entry_wait fix.
Message-Id: <20080618155233.7dd79312.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200806181642.38379.nickpiggin@yahoo.com.au>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<200806181535.58036.nickpiggin@yahoo.com.au>
	<20080618150436.dca5eb75.kamezawa.hiroyu@jp.fujitsu.com>
	<200806181642.38379.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jun 2008 16:42:37 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > (This fix is not related to lock_page() problem.)
> >
> > If I read your advice correctly, we shouldn't use lock_page() here.
> >
> > Before speculative page cache, page_table_entry of a page under migration
> > has a pte entry which encodes pfn as special pte entry. and wait for the
> > end of page migration by lock_page().
> 
> What I don't think I understand, is how we can have a page in the
> page tables (and with the ptl held) but with a zero refcount... Oh,
> it's not actually a page but a migration entry! I'm not quite so
> familiar with that code.
> 
> Hmm, so we might possibly see a page there that has a zero refcount
> due to page_freeze_refs? In which case, I think the direction of you
> fix is good. Sorry for my misunderstanding the problem, and thank
> you for fixing up my code!
> 
> I would ask you to use get_page_unless_zero rather than
> page_cache_get_speculative(), because it's not exactly a speculative
> reference -- a speculative reference is one where we elevate _count
> and then must recheck that the page we have is correct.
> 
ok.

> Also, please add a comment. It would really be nicer to hide this
> transiently-frozen state away from migration_entry_wait, but I can't
> see any lock that would easily solve it.
> 
ok, will adds comments.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
