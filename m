Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8FFD76B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:19:51 -0400 (EDT)
Date: Wed, 18 Aug 2010 11:13:03 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Over-eager swapping
In-Reply-To: <20100818155825.GA2370@arachsys.com>
Message-ID: <alpine.DEB.2.00.1008181112510.6294@router.home>
References: <20100804022148.GA5922@localhost> <AANLkTi=wRPXY9BTuoCe_sDCwhnRjmmwtAf_bjDKG3kXQ@mail.gmail.com> <20100804032400.GA14141@localhost> <20100804095811.GC2326@arachsys.com> <20100804114933.GA13527@localhost> <20100804120430.GB23551@arachsys.com>
 <20100818143801.GA9086@localhost> <20100818144655.GX2370@arachsys.com> <20100818152103.GA11268@localhost> <1282147034.77481.33.camel@useless.localdomain> <20100818155825.GA2370@arachsys.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, Chris Webb wrote:

> > != 0.  And even then, zone reclaim should only reclaim file pages, not
> > anon.  In theory...
>
> Hi. This is zero on all our machines:
>
> # sysctl vm.zone_reclaim_mode
> vm.zone_reclaim_mode = 0

Set it to 1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
