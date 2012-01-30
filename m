Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id B081B6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 01:32:32 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A8F093EE0C2
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:32:30 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FABB3266C2
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:32:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 66CAC206FC5
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:32:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 53E961DB804C
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:32:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F15161DB8051
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:32:29 +0900 (JST)
Date: Mon, 30 Jan 2012 15:31:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] pagemap: introduce data structure for pagemap entry
Message-Id: <20120130153111.4fefb09a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1327705373-29395-7-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1327705373-29395-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1327705373-29395-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Fri, 27 Jan 2012 18:02:53 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently a local variable of pagemap entry in pagemap_pte_range()
> is named pfn and typed with u64, but it's not correct (pfn should
> be unsigned long.)
> This patch introduces special type for pagemap entry and replace
> code with it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  fs/proc/task_mmu.c |   66 +++++++++++++++++++++++++++------------------------
>  1 files changed, 35 insertions(+), 31 deletions(-)
> 
> diff --git 3.3-rc1.orig/fs/proc/task_mmu.c 3.3-rc1/fs/proc/task_mmu.c
> index e2063d9..c2807a3 100644
> --- 3.3-rc1.orig/fs/proc/task_mmu.c
> +++ 3.3-rc1/fs/proc/task_mmu.c
> @@ -586,9 +586,13 @@ const struct file_operations proc_clear_refs_operations = {
>  	.llseek		= noop_llseek,
>  };
>  
> +typedef struct {
> +	u64 pme;
> +} pme_t;
> +

A nitpick..

How about pagemap_entry_t rather than pme_t ?

At 1st look, I wondered whether this is a new kind of page table entry type or not ..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
