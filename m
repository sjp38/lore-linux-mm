Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0F16B004A
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 21:31:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 612663EE0B6
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:31:03 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 493B245DF2C
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:31:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D79745DF28
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:31:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FE1F1DB8038
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:31:03 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E047F1DB803C
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:31:02 +0900 (JST)
Date: Mon, 13 Jun 2011 10:23:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix wrong decision of noswap with
 softlimit.
Message-Id: <20110613102358.95637755.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110612112228.GC19493@tiehlicka.suse.cz>
References: <20110609095445.5f98b752.kamezawa.hiroyu@jp.fujitsu.com>
	<20110612112228.GC19493@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Sun, 12 Jun 2011 13:22:28 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> Hierarchical reclaim doesn't swap out if memsw and resource limits are
> same (memsw_is_minimum == true) because we would hit mem+swap limit
> anyway (during hard limit reclaim).
> If it comes to the solft limit we shouldn't consider memsw_is_minimum at
> all because it doesn't make much sense. Either the soft limit is bellow
> the hard limit and then we cannot hit mem+swap limit or the direct
> reclaim takes a precedence.

Thank you. I'd like to use your description.

I'll post last week bug fixes series, today.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
