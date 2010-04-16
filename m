Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4A4B56B01EF
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 12:03:14 -0400 (EDT)
Date: Fri, 16 Apr 2010 11:02:27 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
In-Reply-To: <r2hcf18f8341004151802g2bc338c0sb1e815c0a14e7474@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004161101460.7710@router.home>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>  <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>  <20100413083855.GS25756@csn.ul.ie>  <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>
 <alpine.DEB.2.00.1004151939310.17800@router.home> <r2hcf18f8341004151802g2bc338c0sb1e815c0a14e7474@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 16 Apr 2010, Bob Liu wrote:

> >> If move to the next node instead of early return, the relative position of the
> >> page to the beginning of the node set will be break;
> >
> > Right.
> >
>
> Thanks!
> Then would you please acking this patch?  So as mel.

Which patch? Could you clarify what you are trying to do?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
