Date: Thu, 19 Jun 2008 09:22:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Experimental][PATCH] putback_lru_page rework
Message-Id: <20080619092242.79648592.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1213813266.6497.14.camel@lts-notebook>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	<20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	<20080618184000.a855dfe0.kamezawa.hiroyu@jp.fujitsu.com>
	<1213813266.6497.14.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jun 2008 14:21:06 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> On Wed, 2008-06-18 at 18:40 +0900, KAMEZAWA Hiroyuki wrote:
> > Lee-san, how about this ?
> > Tested on x86-64 and tried Nisimura-san's test at el. works good now.
> 
> I have been testing with my work load on both ia64 and x86_64 and it
> seems to be working well.  I'll let them run for a day or so.
> 
thank you.
<snip>

> > @@ -240,6 +232,9 @@ static int __munlock_pte_handler(pte_t *
> >  	struct page *page;
> >  	pte_t pte;
> >  
> > +	/*
> > +	 * page is never be unmapped by page-reclaim. we lock this page now.
> > +	 */
> 
> I don't understand what you're trying to say here.  That is, what the
> point of this comment is...
> 
We access the page-table without taking pte_lock. But this vm is MLOCKED
and migration-race is handled. So we don't need to be too nervous to access
the pte. I'll consider more meaningful words.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
