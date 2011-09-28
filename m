Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CDBA99000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 02:04:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 11E0C3EE0C1
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:04:44 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ED60345DE5A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:04:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA48145DE56
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:04:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BC01B1DB8053
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:04:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D0EC1DB804A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:04:43 +0900 (JST)
Date: Wed, 28 Sep 2011 15:03:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V10 3/6] mm: frontswap: core frontswap functionality
Message-Id: <20110928150345.d05186e3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110915213406.GA26369@ca-server1.us.oracle.com>
References: <20110915213406.GA26369@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Thu, 15 Sep 2011 14:34:06 -0700
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> Subject: [PATCH V10 3/6] mm: frontswap: core frontswap functionality
> 
> (Note to earlier reviewers:  This patchset has been reorganized due to
> feedback from Kame Hiroyuki and Andrew Morton. This patch contains part
> of patch 3of4 from the previous series.)
> 
> This third patch of six in the frontswap series provides the core
> frontswap code that interfaces between the hooks in the swap subsystem
> and a frontswap backend via frontswap_ops.
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
> 

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
