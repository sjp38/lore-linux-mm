Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 015926B01F6
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 10:40:05 -0400 (EDT)
Date: Thu, 22 Apr 2010 09:38:43 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
In-Reply-To: <m2vcf18f8341004211803x1392ee7ftc92a1d803316bcee@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004220936100.31660@router.home>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>  <20100413083855.GS25756@csn.ul.ie>  <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>  <20100416111539.GC19264@csn.ul.ie>  <o2kcf18f8341004160803v9663d602g8813b639024b5eca@mail.gmail.com>
  <alpine.DEB.2.00.1004161049130.7710@router.home>  <m2vcf18f8341004170654tc743e4b0s73a0e234cfdcda93@mail.gmail.com>  <alpine.DEB.2.00.1004191245250.9855@router.home>  <w2ucf18f8341004191908v2546cfffo3cc7615802ca1c80@mail.gmail.com>
 <alpine.DEB.2.00.1004210909110.4959@router.home> <m2vcf18f8341004211803x1392ee7ftc92a1d803316bcee@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010, Bob Liu wrote:

> Just one small point, why do_move_pages() in migrate.c needs GFP_THISNODE ?

Because the move_pages function call allows the user explicitly specify
the node for each page. If we cannot move the page to the node the user
wants then the best fallback is to keep it where it was.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
