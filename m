Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 5A9336B005D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 02:33:51 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F05C83EE0B5
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:33:49 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D630645DE5A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:33:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BDE0645DE54
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:33:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF7E21DB804B
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:33:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 64F281DB8052
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:33:49 +0900 (JST)
Message-ID: <4FF291BE.7030509@jp.fujitsu.com>
Date: Tue, 03 Jul 2012 15:31:26 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] memcg: add per cgroup writeback pages accounting
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com> <1340881525-5835-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1340881525-5835-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

(2012/06/28 20:05), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Similar to dirty page, we add per cgroup writeback pages accounting. The lock
> rule still is:
> 	mem_cgroup_begin_update_page_stat()
> 	modify page WRITEBACK stat
> 	mem_cgroup_update_page_stat()
> 	mem_cgroup_end_update_page_stat()
> 
> There're two writeback interface to modify: test_clear/set_page_writeback.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Seems good to me. BTW, you named macros as MEM_CGROUP_STAT_FILE_XXX
but I wonder these counters will be used for accounting swap-out's dirty pages..

STAT_DIRTY, STAT_WRITEBACK ? do you have better name ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
