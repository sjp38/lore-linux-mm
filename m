Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 08C026B0044
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 19:29:47 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBL0TjNw021967
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 21 Dec 2009 09:29:45 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E016E45DE3E
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 09:29:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B5A8645DE52
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 09:29:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BC501DB803F
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 09:29:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C076D1DB8038
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 09:29:43 +0900 (JST)
Date: Mon, 21 Dec 2009 09:26:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 28 of 28] memcg huge memory
Message-Id: <20091221092625.4aef2c3a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091220183943.GA6429@random.random>
References: <patchbomb.1261076403@v2.random>
	<d9c8d2160feb7d82736b.1261076431@v2.random>
	<20091218103312.2f61bbfc.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218160437.GP29790@random.random>
	<ed35473ab7bac5ea2c509e82220565a4.squirrel@webmail-b.css.fujitsu.com>
	<20091220183943.GA6429@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, 20 Dec 2009 19:39:43 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Sat, Dec 19, 2009 at 08:06:50AM +0900, KAMEZAWA Hiroyuki wrote:
> > My intentsion was adding a patch for adding "pagesize" parameters
> > to charge/uncharge function may be able to reduce size of changes.
> 
> There's no need for that as my patch shows and I doubt it makes a lot
> of difference at runtime, but it's up to you, I'm neutral. I suggest
> is that you send me a patch and I integrate and use your version
> ;). I'll take care of adapting huge_memory.c myself if you want to add
> the size param to the outer call.
> 
Added CC: to Nishimura.

Andrea, Please go ahead as you like. My only concern is a confliction with
Nishimura's work. He's preparing a patch for "task move", which has been
requested since the start of memcg. He've done really good jobs and enough
tests in these 2 months.

So, what I think now is to merge Nishimura's to mmotm first and import your
patches on it if Nishimura-san can post ready-to-merge version in this year.
Nishimura-san, what do you think ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
