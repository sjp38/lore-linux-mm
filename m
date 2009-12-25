Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 35A10620002
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 23:24:16 -0500 (EST)
Date: Fri, 25 Dec 2009 13:17:00 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 28 of 28] memcg huge memory
Message-Id: <20091225131700.3db3fb4f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091221133315.7d21ccae.nishimura@mxp.nes.nec.co.jp>
References: <patchbomb.1261076403@v2.random>
	<d9c8d2160feb7d82736b.1261076431@v2.random>
	<20091218103312.2f61bbfc.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218160437.GP29790@random.random>
	<ed35473ab7bac5ea2c509e82220565a4.squirrel@webmail-b.css.fujitsu.com>
	<20091220183943.GA6429@random.random>
	<20091221092625.4aef2c3a.kamezawa.hiroyu@jp.fujitsu.com>
	<20091221102427.8b22467f.nishimura@mxp.nes.nec.co.jp>
	<20091221125223.4ae56520.kamezawa.hiroyu@jp.fujitsu.com>
	<20091221133315.7d21ccae.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 13:33:15 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> On Mon, 21 Dec 2009 12:52:23 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 21 Dec 2009 10:24:27 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Mon, 21 Dec 2009 09:26:25 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > Added CC: to Nishimura.
> > > > 
> > > > Andrea, Please go ahead as you like. My only concern is a confliction with
> > > > Nishimura's work.
> > > I agree. I've already noticed Andrea's patches but not read through all the
> > > patches yet, sorry.
> > > 
> > > One concern: isn't there any inconsistency to handle css->refcnt in charging/uncharging
> > > compound pages the same way as a normal page ?
> > > 
> > AKAIK, no inconsistency.
> O.K. thanks.
> (It might be better for us to remove per page css refcnt till 2.6.34...)
> 
Hmm, if I understand these patches correctly, some inconsistency about css->refcnt
and page_cgroup of tail pages happen when a huge page is splitted.
At least, I think pc->flags and pc->mem_cgroup of them should be handled.

So, I think we need some hooks in __split_huge_page_map() or some tricks.

> > My biggest concern is that page-table-walker has to handle hugepages. 
> > 
> Ah, you're right.
> It would be a big change..
> 
In [19/28] of this version, split_huge_page_mm() is called in walk_pmd_range().
So, I think it will work w/o changing current code.
(It might be better to change my code, which does all the works in walk->pmd_entry(),
to prevent unnecessary splitting.)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
