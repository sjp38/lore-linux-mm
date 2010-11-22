Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 243B46B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 07:01:57 -0500 (EST)
Received: by iwn33 with SMTP id 33so3332119iwn.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 04:01:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101119171653.3c476064.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20101119171653.3c476064.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 22 Nov 2010 21:01:54 +0900
Message-ID: <AANLkTikWeMH67nOSA-s3+OZqovyNRNoTw8wTr5_ecpOv@mail.gmail.com>
Subject: Re: [PATCH 4/4] alloc_contig_pages() use better allocation function
 for migration
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 5:16 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Old story.
> Because we cannot assume which memory section will be offlined next,
> hotremove_migrate_alloc() just uses alloc_page(). i.e. make no decision
> where the page should be migrate into. Considering memory hotplug's
> nature, the next memory section near to a section which is being removed
> will be removed in the next. So, migrate pages to the same node of original
> page doesn't make sense in many case, it just increases load.
> Migration destination page is allocated from the node where offlining script
> runs.
>
> Now, contiguous-alloc uses do_migrate_range(). In this case, migration
> destination node should be the same node of migration source page.
>
> This patch modifies hotremove_migrate_alloc() and pass "nid" to it.
> Memory hotremove will pass -1. So, if the page will be moved to
> the node where offlining script runs....no behavior changes.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
