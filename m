Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7396B0044
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 20:34:56 -0500 (EST)
Date: Mon, 21 Dec 2009 10:24:27 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 28 of 28] memcg huge memory
Message-Id: <20091221102427.8b22467f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091221092625.4aef2c3a.kamezawa.hiroyu@jp.fujitsu.com>
References: <patchbomb.1261076403@v2.random>
	<d9c8d2160feb7d82736b.1261076431@v2.random>
	<20091218103312.2f61bbfc.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218160437.GP29790@random.random>
	<ed35473ab7bac5ea2c509e82220565a4.squirrel@webmail-b.css.fujitsu.com>
	<20091220183943.GA6429@random.random>
	<20091221092625.4aef2c3a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 09:26:25 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Sun, 20 Dec 2009 19:39:43 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > On Sat, Dec 19, 2009 at 08:06:50AM +0900, KAMEZAWA Hiroyuki wrote:
> > > My intentsion was adding a patch for adding "pagesize" parameters
> > > to charge/uncharge function may be able to reduce size of changes.
> > 
> > There's no need for that as my patch shows and I doubt it makes a lot
> > of difference at runtime, but it's up to you, I'm neutral. I suggest
> > is that you send me a patch and I integrate and use your version
> > ;). I'll take care of adapting huge_memory.c myself if you want to add
> > the size param to the outer call.
> > 
> Added CC: to Nishimura.
> 
> Andrea, Please go ahead as you like. My only concern is a confliction with
> Nishimura's work.
I agree. I've already noticed Andrea's patches but not read through all the
patches yet, sorry.

One concern: isn't there any inconsistency to handle css->refcnt in charging/uncharging
compound pages the same way as a normal page ?

> He's preparing a patch for "task move", which has been
> requested since the start of memcg. He've done really good jobs and enough
> tests in these 2 months.
> 
> So, what I think now is to merge Nishimura's to mmotm first and import your
> patches on it if Nishimura-san can post ready-to-merge version in this year.
> Nishimura-san, what do you think ?
> 
I would say, "yes. I agree with you" ;)
Anyway, I'm preparing my patches for next post, in which I've fixed the bug
I found in previous(Dec/14) version. I'll post them today or tomorrow at the latest
and I think they are ready to be merged.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
