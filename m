Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A7EE69000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 02:10:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 426A63EE0CB
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:10:44 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1219B45DE61
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:10:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D380945DE59
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:10:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BEE61E18004
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:10:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 879371DB8048
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:10:43 +0900 (JST)
Date: Wed, 28 Sep 2011 15:09:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V10 6/6] mm: frontswap/cleancache: final
 flush->invalidate
Message-Id: <20110928150948.8071aa22.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110915213506.GA26426@ca-server1.us.oracle.com>
References: <20110915213506.GA26426@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Thu, 15 Sep 2011 14:35:06 -0700
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> Subject: [PATCH V10 6/6] mm: frontswap/cleancache: final flush->invalidate
> 
> This sixth patch of six in this frontswap series completes the renaming
> from "flush" to "invalidate" across both tmem frontends (cleancache and
> frontswap) and both tmem backends (Xen and zcache), as required by akpm.
> This change is completely cosmetic.
> 
> [v10: no change]
> [v9: akpm@linux-foundation.org: change "flush" to "invalidate", part 3]
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
