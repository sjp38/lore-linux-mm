Date: Fri, 26 Sep 2008 18:18:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/12] memcg move charege() call to swapped-in page under
 lock_page()
Message-Id: <20080926181803.351e94cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48DC9EF2.10004@linux.vnet.ibm.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925151457.0ad68293.kamezawa.hiroyu@jp.fujitsu.com>
	<48DC9EF2.10004@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 14:06:02 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > While page-cache's charge/uncharge is done under page_lock(), swap-cache
> > isn't. (anonymous page is charged when it's newly allocated.)
> > 
> > This patch moves do_swap_page()'s charge() call under lock. This helps
> > us to avoid to charge already mapped one, unnecessary calls.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Seems reasonable to me
> 
> Just one quick comment though, as a result of this change, mark_page_accessed is
> now called with PageLock held, I suspect you would want to move that call prior
> to lock_page().
> 
Ok. I'll check it

Thanks,
-Kame
> 
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
