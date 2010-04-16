Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D9E756B01F6
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 12:19:46 -0400 (EDT)
Date: Fri, 16 Apr 2010 11:15:58 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
In-Reply-To: <v2qcf18f8341004130009o49bd230cga838b416a75f61e8@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004161115000.7710@router.home>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>  <20100412164335.GQ25756@csn.ul.ie>  <i2l28c262361004122134of7f96809va209e779ccd44195@mail.gmail.com>  <20100413144037.f714fdeb.kamezawa.hiroyu@jp.fujitsu.com>
 <v2qcf18f8341004130009o49bd230cga838b416a75f61e8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 13 Apr 2010, Bob Liu wrote:

> What I concern is *just* we shouldn't fallback to other nodes if the
> dest node haven't enough free pages during migrate_pages().

Why not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
