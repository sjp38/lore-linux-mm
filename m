Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E51536B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 01:40:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DB6EA3EE0C5
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 14:40:49 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B311045DEB7
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 14:40:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9281B45DE9E
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 14:40:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 82D6B1DB8042
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 14:40:49 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 478C21DB803B
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 14:40:49 +0900 (JST)
Date: Thu, 25 Aug 2011 14:33:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure
 changes
Message-Id: <20110825143312.a6fe93d5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110823145755.GA23174@ca-server1.us.oracle.com>
References: <20110823145755.GA23174@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

On Tue, 23 Aug 2011 07:57:55 -0700
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> Subject: [PATCH V7 1/4] mm: frontswap: swap data structure changes
> 
> This first patch of four in the frontswap series makes available core
> swap data structures (swap_lock, swap_list and swap_info) that are
> needed by frontswap.c but we don't need to expose them to the dozens
> of files that include swap.h so we create a new swapfile.h just to
> extern-ify these.
> 
> Also add frontswap-related elements to swap_info_struct.  Frontswap_map
> points to vzalloc'ed one-bit-per-swap-page metadata that indicates
> whether the swap page is in frontswap or in the device and frontswap_pages
> counts how many pages are in frontswap.
> 
> [v7: rebase to 3.0-rc3]
> [v7: JBeulich@novell.com: add new swap struct elements only if config'd]
> [v6: rebase to 3.0-rc1]
> [v5: no change from v4]
> [v4: rebase to 2.6.39]
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
> Acked-by: Jan Beulich <JBeulich@novell.com>
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Matthew Wilcox <matthew@wil.cx>
> Cc: Chris Mason <chris.mason@oracle.com>
> Cc: Rik Riel <riel@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Hmm....could you modify mm/swapfile.c and remove 'static' in the same patch ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
