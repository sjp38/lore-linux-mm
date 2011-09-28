Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 349DC9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 01:59:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DFEE43EE0C1
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 14:59:41 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C28A245DF4C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 14:59:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A762A45DE80
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 14:59:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A61C1DB8042
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 14:59:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 620781DB8037
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 14:59:41 +0900 (JST)
Date: Wed, 28 Sep 2011 14:58:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V10 1/6] mm: frontswap: add frontswap header file
Message-Id: <20110928145848.4cd2cd9d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110915213325.GA26333@ca-server1.us.oracle.com>
References: <20110915213325.GA26333@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Thu, 15 Sep 2011 14:33:25 -0700
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> This first patch of six in this frontswap series provides the header
> file for the core code for frontswap that interfaces between the hooks
> in the swap subsystem and a frontswap backend via frontswap_ops.
> (Note to earlier reviewers:  This patchset has been reorganized due to
> feedback from Kame Hiroyuki and Andrew Morton. This patch contains part
> of patch 3of4 from the previous series.)
> 
> New file added: include/linux/frontswap.h
> 
> [v10: no change]
> [v9: akpm@linux-foundation.org: change "flush" to "invalidate", part 1]
> [v8: rebase to 3.0-rc4]
> [v7: rebase to 3.0-rc3]
> [v7: JBeulich@novell.com: new static inlines resolve to no-ops if not config'd]
> [v7: JBeulich@novell.com: avoid redundant shifts/divides for *_bit lib calls]
> [v6: rebase to 3.1-rc1]
> [v5: no change from v4]
> [v4: rebase to 2.6.39]
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Jan Beulich <JBeulich@novell.com>
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
