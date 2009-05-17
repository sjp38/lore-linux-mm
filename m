Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 225E36B004F
	for <linux-mm@kvack.org>; Sat, 16 May 2009 20:34:35 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so1306722ywm.26
        for <linux-mm@kvack.org>; Sat, 16 May 2009 17:35:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090516090448.249602749@intel.com>
References: <20090516090005.916779788@intel.com>
	 <20090516090448.249602749@intel.com>
Date: Sun, 17 May 2009 09:35:06 +0900
Message-ID: <28c262360905161735s291fc34ah845eb5f82e1ada25@mail.gmail.com>
Subject: Re: [PATCH 1/3] vmscan: report vm_flags in page_referenced()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, May 16, 2009 at 6:00 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> Collect vma->vm_flags of the VMAs that actually referenced the page.
>
> This is preparing for more informed reclaim heuristics,
> eg. to protect executable file pages more aggressively.
> For now only the VM_EXEC bit will be used by the caller.
>
> CC: Minchan Kim <minchan.kim@gmail.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
