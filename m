Received: from l-036148a.enterprise.veritas.com([10.10.97.179]) (1751 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1IuC07-00006PC@megami.veritas.com>
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 11:09:43 -0800 (PST)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Mon, 19 Nov 2007 19:09:25 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page_referenced() and VM_LOCKED
In-Reply-To: <20071119183942.614771c2.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0711191906190.14816@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0711161749020.12201@blonde.wat.veritas.com>
 <473D1BC9.8050904@google.com> <20071116144641.f12fd610.kamezawa.hiroyu@jp.fujitsu.com>
 <16909246.1195259556869.kamezawa.hiroyu@jp.fujitsu.com>
 <20071119183942.614771c2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Nov 2007, KAMEZAWA Hiroyuki wrote:
> > 
> your patch helps the kernel to avoid a waste of Swap.
> 
> Tested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Many thanks, Kame.  I'll send it in with my next little lot.
Hugh

> ==
> I tested your patch on x86_64/6GiB memory, + 2.6.24-rc3.
> mlock 5GiB and create 4GiB file by"dd".
> 
> [before patch]
> MemTotal:      6072620 kB
> MemFree:         50540 kB
> Buffers:          4508 kB
> Cached:         724828 kB
> SwapCached:    5146960 kB
> Active:        2683964 kB
> Inactive:      3198752 kB
> 
> [after patch]
> MemTotal:      6072620 kB
> MemFree:         17112 kB
> Buffers:          6816 kB
> Cached:         744880 kB
> SwapCached:      21724 kB
> Active:        5175828 kB
> Inactive:       744956 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
