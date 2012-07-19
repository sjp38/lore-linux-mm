Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D2BE56B0069
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 06:01:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9FBD83EE0AE
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:01:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 86FE045DE5B
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:01:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C05545DE59
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:01:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E5101DB803A
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:01:08 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 151F01DB802C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:01:08 +0900 (JST)
Message-ID: <5007DA01.5060903@jp.fujitsu.com>
Date: Thu, 19 Jul 2012 18:57:21 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 03/10] mm: memcg: push down PageSwapCache check into uncharge
 entry functions
References: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org> <1342026142-7284-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1342026142-7284-4-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/12 2:02), Johannes Weiner wrote:
> Not all uncharge paths need to check if the page is swapcache, some of
> them can know for sure.
> 
> Push down the check into all callsites of uncharge_common() so that
> the patch that removes some of them is more obvious.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
