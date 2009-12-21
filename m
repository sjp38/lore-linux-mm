Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4250D6B0071
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 22:56:01 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBL3tv01013707
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 21 Dec 2009 12:55:57 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A8DA45DE57
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 12:55:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4470745DE51
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 12:55:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 27D041DB803E
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 12:55:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CA66F1DB8038
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 12:55:56 +0900 (JST)
Date: Mon, 21 Dec 2009 12:52:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 28 of 28] memcg huge memory
Message-Id: <20091221125223.4ae56520.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091221102427.8b22467f.nishimura@mxp.nes.nec.co.jp>
References: <patchbomb.1261076403@v2.random>
	<d9c8d2160feb7d82736b.1261076431@v2.random>
	<20091218103312.2f61bbfc.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218160437.GP29790@random.random>
	<ed35473ab7bac5ea2c509e82220565a4.squirrel@webmail-b.css.fujitsu.com>
	<20091220183943.GA6429@random.random>
	<20091221092625.4aef2c3a.kamezawa.hiroyu@jp.fujitsu.com>
	<20091221102427.8b22467f.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 10:24:27 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Mon, 21 Dec 2009 09:26:25 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Added CC: to Nishimura.
> > 
> > Andrea, Please go ahead as you like. My only concern is a confliction with
> > Nishimura's work.
> I agree. I've already noticed Andrea's patches but not read through all the
> patches yet, sorry.
> 
> One concern: isn't there any inconsistency to handle css->refcnt in charging/uncharging
> compound pages the same way as a normal page ?
> 
AKAIK, no inconsistency.
My biggest concern is that page-table-walker has to handle hugepages. 


> > He's preparing a patch for "task move", which has been
> > requested since the start of memcg. He've done really good jobs and enough
> > tests in these 2 months.
> > 
> > So, what I think now is to merge Nishimura's to mmotm first and import your
> > patches on it if Nishimura-san can post ready-to-merge version in this year.
> > Nishimura-san, what do you think ?
> > 
> I would say, "yes. I agree with you" ;)
> Anyway, I'm preparing my patches for next post, in which I've fixed the bug
> I found in previous(Dec/14) version. I'll post them today or tomorrow at the latest
> and I think they are ready to be merged.
> 
Ok, great.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
