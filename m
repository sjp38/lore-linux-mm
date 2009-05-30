Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 038836B00C1
	for <linux-mm@kvack.org>; Sat, 30 May 2009 07:35:26 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4UBVO8C004677
	for <linux-mm@kvack.org>; Sat, 30 May 2009 07:31:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4UBZwDA250648
	for <linux-mm@kvack.org>; Sat, 30 May 2009 07:35:58 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4UBZwkw026181
	for <linux-mm@kvack.org>; Sat, 30 May 2009 07:35:58 -0400
Date: Sat, 30 May 2009 19:35:54 +0800
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] modify swap_map and add SWAP_HAS_CACHE flag.
Message-ID: <20090530113554.GN24073@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com> <20090528141900.c93fe1d5.kamezawa.hiroyu@jp.fujitsu.com> <20090530061008.GE24073@balbir.in.ibm.com> <c22c9214cc3a6fcf2224fa556f5558b1.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <c22c9214cc3a6fcf2224fa556f5558b1.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-30 20:16:51]:

> Balbir Singh wrote:
> >>  #define SWAP_CLUSTER_MAX 32
> >>
> >> -#define SWAP_MAP_MAX	0x7fff
> >> -#define SWAP_MAP_BAD	0x8000
> >> -
> >> +#define SWAP_MAP_MAX	0x7ffe
> >> +#define SWAP_MAP_BAD	0x7fff
> >> +#define SWAP_HAS_CACHE  0x8000		/* There is a swap cache of entry. */
> >
> > Why count, can't we use swp->flags?
> >
> 
> Hmm ? swap_map just only a "unsiged short" value per entry..sorry,
> I can't catch what you mention to.

Sorry for the noise, the count is directly contained in swap_map[].

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
