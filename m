Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6BA906B0078
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 04:18:25 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o868IMt2003091
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 6 Sep 2010 17:18:23 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C11545DE79
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:18:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 242C845DE6F
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:18:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F2A5B1DB8040
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:18:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ABA051DB803B
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:18:21 +0900 (JST)
Date: Mon, 6 Sep 2010 17:13:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] swap: revert special hibernation allocation
Message-Id: <20100906171307.9e8d9637.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1009060104410.13600@sister.anvils>
References: <alpine.LSU.2.00.1009060104410.13600@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Ondrej Zary <linux@rainbow-software.org>, Andrea Gelmini <andrea.gelmini@gmail.com>, Balbir Singh <balbir@in.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Nigel Cunningham <nigel@tuxonice.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Sep 2010 01:10:55 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> Please revert 2.6.36-rc commit d2997b1042ec150616c1963b5e5e919ffd0b0ebf
> "hibernation: freeze swap at hibernation".  It complicated matters by
> adding a second swap allocation path, just for hibernation; without in
> any way fixing the issue that it was intended to address - page reclaim
> after fixing the hibernation image might free swap from a page already
> imaged as swapcache, letting its swap be reallocated to store a different
> page of the image: resulting in data corruption if the imaged page were
> freed as clean then swapped back in.  Pages freed to si->swap_map were
> still in danger of being reallocated by the alternative allocation path.
> 
> I guess it inadvertently fixed slow SSD swap allocation for hibernation,
> as reported by Nigel Cunningham: by missing out the discards that occur
> on the usual swap allocation path; but that was unintentional, and needs
> a separate fix.
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

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
