Date: Tue, 26 Feb 2008 02:56:14 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 13/15] memcg: fix mem_cgroup_move_lists locking
In-Reply-To: <20080226104303.5db0df8e.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0802260254290.14896@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
 <Pine.LNX.4.64.0802252347160.27067@blonde.site>
 <20080226104303.5db0df8e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2008, KAMEZAWA Hiroyuki wrote:
> On Mon, 25 Feb 2008 23:49:04 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> > 
> > This patch immediately gets replaced by a simpler one from Hirokazu-san;
> > but is it just foolish pride that tells me to put this one on record,
> > in case we need to come back to it later?
> > 
> > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> > ---
> yes, we need this patch.
> 
> BTW, what is "a simpler one from Hirokazu-san" ? 

14/15: most of the complexity of this 13/15 is immediately removed in 14/15.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
