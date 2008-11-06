Date: Thu, 6 Nov 2008 11:59:58 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH 7/6] memcg: add atribute (for change bahavior of
 rmdir)
In-Reply-To: <20081106194153.220157ec.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0811061151130.26541@blonde.site>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
 <49129493.9070103@linux.vnet.ibm.com> <20081106194153.220157ec.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Nov 2008, KAMEZAWA Hiroyuki wrote:
> On Thu, 06 Nov 2008 12:24:11 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > KAMEZAWA Hiroyuki wrote:
> > > 
> > > 1. change force_empty to do move account rather than forget all
> > 
> > I would like this to be selectable, please. We don't want to break behaviour and
> > not everyone would like to pay the cost of movement.
> 
> How about a patch like this ? I'd like to move this as [2/7], if possible.
> It obviously needs painful rework. If I found it difficult, schedule this as [7/7].
> 
> BTW, cost of movement itself is not far from cost for force_empty.
> 
> If you can't find why "forget" is bad, please consider one more day.

My recollection from a year ago is that force_empty totally violated
the rules established elsewhere, making a nonsense of it all: once a
force_empty had been done, you couldn't really be sure of anything
(perhaps it deserved a Taint flag).

Without studying your proposals at all, I do believe you've a good
chance of creating a sensible and consistent force_empty by moving
account, and abandoning the old "forget all" approach completely.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
