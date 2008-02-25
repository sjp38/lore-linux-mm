Date: Mon, 25 Feb 2008 15:07:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [6/7] radix-tree
 based page cgroup
Message-Id: <20080225150716.6597da6f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225055631.9A93F1E3C63@siro.lan>
References: <20080225121744.a90704fb.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225055631.9A93F1E3C63@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, taka@valinux.co.jp, ak@suse.de, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 14:56:31 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > struct page *get_page_cgroup(struct page *page, gfp_mask mask);
> > 
> > if (mask != 0), look up and allocate new one if necessary.
> > if (mask == 0), just do look up and return NULL if not exist.
> 
> 0 is a valid gfp mask.  (GFP_NOWAIT)
> 
> YAMAMOTO Takashi
> 
Hmm, maybe adding new arg is better, like

struct get_page_cgroup(struct page* page, gfp_t mask, bool allocate);

I will change. thank you.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
