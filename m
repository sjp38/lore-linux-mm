Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BEF606B01F2
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:57:14 -0400 (EDT)
Date: Wed, 18 Aug 2010 10:57:09 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Over-eager swapping
In-Reply-To: <20100818152103.GA11268@localhost>
Message-ID: <alpine.DEB.2.00.1008181056350.4025@router.home>
References: <20100803042835.GA17377@localhost> <20100803214945.GA2326@arachsys.com> <20100804022148.GA5922@localhost> <AANLkTi=wRPXY9BTuoCe_sDCwhnRjmmwtAf_bjDKG3kXQ@mail.gmail.com> <20100804032400.GA14141@localhost> <20100804095811.GC2326@arachsys.com>
 <20100804114933.GA13527@localhost> <20100804120430.GB23551@arachsys.com> <20100818143801.GA9086@localhost> <20100818144655.GX2370@arachsys.com> <20100818152103.GA11268@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chris Webb <chris@arachsys.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, Wu Fengguang wrote:

> Andi, Christoph and Lee:
>
> This looks like an "unbalanced NUMA memory usage leading to premature
> swapping" problem.

Is zone reclaim active? It may not activate on smaller systems leading
to an unbalance memory usage between node.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
