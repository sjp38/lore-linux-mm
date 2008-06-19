Date: Thu, 19 Jun 2008 18:31:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 5/5] putback_lru_page()/unevictable page handling rework v2
In-Reply-To: <20080619181707.E80E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080619172241.E7FC.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080619181707.E80E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080619182415.E811.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Ah, sorry.
I forgot to write changelog.

V1 -> V2
   o undo unintented comment killing.
   o move putback_lru_page() from move_to_new_page() to unmap_and_move().
   o folded depend patch
       http://marc.info/?l=linux-mm&m=121337119621958&w=2
       http://marc.info/?l=linux-kernel&m=121362782406478&w=2
       http://marc.info/?l=linux-mm&m=121377572909776&w=2


> this patch is folding several patches and obsolete to
> 
> Lee's  "fix double unlock_page()" patches
> 
>    http://marc.info/?l=linux-mm&m=121337119621958&w=2
>    http://marc.info/?l=linux-kernel&m=121362782406478&w=2
> 
> and Nishimura-san's "remove redundant page->mapping check" patch.
> 
>    http://marc.info/?l=linux-mm&m=121377572909776&w=2
> 
> 
> -----------------------------------------
> From: KAMEZAWA Hiroyuki <kamezawa.hiroy@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
