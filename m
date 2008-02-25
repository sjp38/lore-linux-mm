Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [6/7] radix-tree based
 page cgroup
In-Reply-To: Your message of "Mon, 25 Feb 2008 12:17:44 +0900"
	<20080225121744.a90704fb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225121744.a90704fb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080225055631.9A93F1E3C63@siro.lan>
Date: Mon, 25 Feb 2008 14:56:31 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, taka@valinux.co.jp, ak@suse.de, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> struct page *get_page_cgroup(struct page *page, gfp_mask mask);
> 
> if (mask != 0), look up and allocate new one if necessary.
> if (mask == 0), just do look up and return NULL if not exist.

0 is a valid gfp mask.  (GFP_NOWAIT)

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
