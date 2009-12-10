Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 44AED6B0087
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 12:59:26 -0500 (EST)
Date: Thu, 10 Dec 2009 11:59:11 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC mm][PATCH 4/5] add a lowmem check function
In-Reply-To: <20091210170036.dde2c147.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912101155490.5481@router.home>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com> <20091210170036.dde2c147.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 2009, KAMEZAWA Hiroyuki wrote:

> This patch adds an integer lowmem_zone, which is initialized to -1.
> If zone_idx(zone) <= lowmem_zone, the zone is lowmem.

There is already a policy_zone in mempolicy.h. lowmem is if the zone
number is  lower than policy_zone. Can we avoid adding another zone
limiter?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
