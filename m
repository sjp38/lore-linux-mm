Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 013358D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 21:46:46 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CB6FE3EE0BC
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:46:43 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AEA0B45DE56
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:46:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 94F3845DE4D
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:46:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 86CCEE08004
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:46:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5174DE08001
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:46:43 +0900 (JST)
Date: Mon, 28 Feb 2011 11:40:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 6/9] memcg: add kernel calls for memcg dirty page
 stats
Message-Id: <20110228114018.390ce291.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110227170143.GE3226@barrios-desktop>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
	<1298669760-26344-7-git-send-email-gthelen@google.com>
	<20110227170143.GE3226@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Mon, 28 Feb 2011 02:01:43 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Feb 25, 2011 at 01:35:57PM -0800, Greg Thelen wrote:
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> >  	} else {
> > @@ -1365,6 +1368,7 @@ int test_set_page_writeback(struct page *page)
> >  						PAGECACHE_TAG_WRITEBACK);
> >  			if (bdi_cap_account_writeback(bdi))
> >  				__inc_bdi_stat(bdi, BDI_WRITEBACK);
> > +			mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_WRITEBACK);
> 
> Question:
> Why should we care of BDI_CAP_NO_WRITEBACK?
> 
Hmm, should we do ..
==
        if (!ret) {
                account_page_writeback(page);
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_WRITEBACL);
	}
==

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
