Date: Fri, 26 Sep 2008 18:17:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/12] memcg avoid accounting special mappings not on LRU
Message-Id: <20080926181726.359c77a8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48DC9C92.4000408@linux.vnet.ibm.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925151307.f9cf352f.kamezawa.hiroyu@jp.fujitsu.com>
	<48DC9C92.4000408@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 13:55:54 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > There are not-on-LRU pages which can be mapped and they are not worth to
> > be accounted. (becasue we can't shrink them and need dirty codes to handle
> > specical case) We'd like to make use of usual objrmap/radix-tree's protcol
> > and don't want to account out-of-vm's control pages.
> > 
> > When special_mapping_fault() is called, page->mapping is tend to be NULL 
> > and it's charged as Anonymous page.
> > insert_page() also handles some special pages from drivers.
> > 
> > This patch is for avoiding to account special pages.
> > 
> 
> Hmm... I am a little concerned that with these changes actual usage will much
> more than what we report in memory.usage_in_bytes. Why not move them to
> non-reclaimable LRU list as unevictable pages (once those patches go in, we can
> push this as well). 

Because they are not on LRU ...i.e. !PageLRU(page)

> I suspect the size of special pages is too short to affect
> anything or are you seeing something very different?

I don't want put pages never goes to LRU onto memcgroup's LRU.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
