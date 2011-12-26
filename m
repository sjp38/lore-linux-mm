Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7EB6D6B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 03:42:04 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 856323EE0C3
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 17:42:02 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 685B745DF55
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 17:42:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4978245DF07
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 17:42:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E40D1DB803C
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 17:42:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EB2521DB8038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 17:42:01 +0900 (JST)
Date: Mon, 26 Dec 2011 17:40:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] pagemap: export KPF_THP
Message-Id: <20111226174045.b1ae9bd1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1324506228-18327-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1324506228-18327-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Wed, 21 Dec 2011 17:23:47 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> This flag shows that a given pages is a subpage of transparent hugepage.
> It helps us debug and test kernel by showing physical address of thp.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Nacked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
