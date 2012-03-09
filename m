Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 7B2736B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 19:35:12 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 869513EE0B5
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 09:35:10 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C44945DE53
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 09:35:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 52E4445DE52
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 09:35:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 41E281DB803A
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 09:35:10 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E98D71DB803E
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 09:35:09 +0900 (JST)
Date: Fri, 9 Mar 2012 09:33:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 1/2] thp: add HPAGE_PMD_* definitions for
 !CONFIG_TRANSPARENT_HUGEPAGE
Message-Id: <20120309093331.9fc91231.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri,  2 Mar 2012 15:13:08 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> These macros will be used in later patch, where all usage are expected
> to be optimized away without #ifdef CONFIG_TRANSPARENT_HUGEPAGE.
> But to detect unexpected usages, we convert existing BUG() to BUILD_BUG().
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Hillf Danton <dhillf@gmail.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
