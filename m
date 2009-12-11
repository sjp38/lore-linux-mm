Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3533B6B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:35:17 -0500 (EST)
Date: Fri, 11 Dec 2009 07:35:02 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC mm][PATCH 4/5] add a lowmem check function
In-Reply-To: <20091211093938.70214f9c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912110733310.30295@router.home>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com> <20091210170036.dde2c147.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0912101155490.5481@router.home> <20091211093938.70214f9c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, Ingo Molnar <mingo@elte.hu>, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 11 Dec 2009, KAMEZAWA Hiroyuki wrote:

> Hmm, How about adding following kind of patch after this
>
> #define policy_zone (lowmem_zone + 1)
>
> and remove policy_zone ? I think the name of "policy_zone" implies
> "this is for mempolicy, NUMA" and don't think good name for generic use.

Good idea but lets hear Lee's opinion about this one too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
