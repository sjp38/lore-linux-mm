Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AE8206B004A
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 14:35:55 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 2/4] swap: prevent reuse during hibernation
Date: Mon, 6 Sep 2010 20:34:36 +0200
References: <alpine.LSU.2.00.1009060104410.13600@sister.anvils> <alpine.LSU.2.00.1009060111220.13600@sister.anvils> <20100906171504.f06918a1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100906171504.f06918a1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201009062034.36437.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ondrej Zary <linux@rainbow-software.org>, Andrea Gelmini <andrea.gelmini@gmail.com>, Balbir Singh <balbir@in.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Nigel Cunningham <nigel@tuxonice.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday, September 06, 2010, KAMEZAWA Hiroyuki wrote:
> On Mon, 6 Sep 2010 01:12:38 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > Move the hibernation check from scan_swap_map() into try_to_free_swap():
> > to catch not only the common case when hibernation's allocation itself
> > triggers swap reuse, but also the less likely case when concurrent page
> > reclaim (shrink_page_list) might happen to try_to_free_swap from a page.
> > 
> > Hibernation already clears __GFP_IO from the gfp_allowed_mask, to stop
> > reclaim from going to swap: check that to prevent swap reuse too.
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> > Cc: Ondrej Zary <linux@rainbow-software.org>
> > Cc: Andrea Gelmini <andrea.gelmini@gmail.com>
> > Cc: Balbir Singh <balbir@in.ibm.com>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Nigel Cunningham <nigel@tuxonice.net>
> > Cc: stable@kernel.org
> 
> Hmm...seems better.
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Rafael J. Wysocki <rjw@sisk.pl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
