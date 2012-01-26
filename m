Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3461E6B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 19:20:37 -0500 (EST)
Date: Wed, 25 Jan 2012 16:20:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: adjust rss counters for migration entiries
Message-Id: <20120125162035.32766a1c.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1201251453550.2141@eggly.anvils>
References: <20120106173827.11700.74305.stgit@zurg>
	<20120106173856.11700.98858.stgit@zurg>
	<20120111144125.0c61f35f.kamezawa.hiroyu@jp.fujitsu.com>
	<4F0D46EF.4060705@openvz.org>
	<20120111174126.f35e708a.kamezawa.hiroyu@jp.fujitsu.com>
	<20120118152131.45a47966.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1201231719580.14979@eggly.anvils>
	<4F1E58DD.6030607@openvz.org>
	<alpine.LSU.2.00.1201251453550.2141@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 25 Jan 2012 15:01:38 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> > > > : From: Konstantin Khlebnikov<khlebnikov@openvz.org>
> > > > : Subject: mm: postpone migrated page mapping reset
> > > > :
> > > > : Postpone resetting page->mapping until the final
> > > > remove_migration_ptes().
> > > > : Otherwise the expression PageAnon(migration_entry_to_page(entry)) does
> > > > not
> > > > : work.
> > > > :
> > > > : Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> > > > : Cc: Hugh Dickins<hughd@google.com>
> > > > : Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > Isn't this one actually an essential part of the fix?  It should have
> > > been part of the same patch, but you split them apart, now Andrew has
> > > reordered them and pushed one part to 3.3, but this needs to go in too?
> > > 
> > 
> > Oops. I missed that. Yes. race-fix does not work for anon-memory without that
> > patch.
> > But this is non-fatal, there are no new bugs.
> 
> Non-fatal and no new bug, yes, but it makes the fix which has already
> gone in rather less of a fix than was intended (it'll get the total right,
> but misreport anon as file).  Andrew, please add this one to your next
> push to Linus - thanks.

Shall do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
