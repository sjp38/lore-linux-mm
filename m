Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A85C6B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 04:20:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o868KBSX003909
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 6 Sep 2010 17:20:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D169C45DE61
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:20:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AB36845DE63
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:20:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 838831DB803B
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:20:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D9C801DB8038
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:20:09 +0900 (JST)
Date: Mon, 6 Sep 2010 17:15:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] swap: prevent reuse during hibernation
Message-Id: <20100906171504.f06918a1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1009060111220.13600@sister.anvils>
References: <alpine.LSU.2.00.1009060104410.13600@sister.anvils>
	<alpine.LSU.2.00.1009060111220.13600@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Ondrej Zary <linux@rainbow-software.org>, Andrea Gelmini <andrea.gelmini@gmail.com>, Balbir Singh <balbir@in.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Nigel Cunningham <nigel@tuxonice.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Sep 2010 01:12:38 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> Move the hibernation check from scan_swap_map() into try_to_free_swap():
> to catch not only the common case when hibernation's allocation itself
> triggers swap reuse, but also the less likely case when concurrent page
> reclaim (shrink_page_list) might happen to try_to_free_swap from a page.
> 
> Hibernation already clears __GFP_IO from the gfp_allowed_mask, to stop
> reclaim from going to swap: check that to prevent swap reuse too.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> Cc: Ondrej Zary <linux@rainbow-software.org>
> Cc: Andrea Gelmini <andrea.gelmini@gmail.com>
> Cc: Balbir Singh <balbir@in.ibm.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Nigel Cunningham <nigel@tuxonice.net>
> Cc: stable@kernel.org

Hmm...seems better.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
