Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id AF46B6B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 21:30:59 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 032643EE0BD
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 11:30:58 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA3B345DE67
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 11:30:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C073345DE55
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 11:30:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B347D1DB802C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 11:30:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A2AF1DB803C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 11:30:57 +0900 (JST)
Date: Thu, 9 Feb 2012 11:29:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] pagemap: introduce data structure for pagemap entry
Message-Id: <20120209112936.1395fc2c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1328716302-16871-7-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1328716302-16871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1328716302-16871-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Wed,  8 Feb 2012 10:51:42 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently a local variable of pagemap entry in pagemap_pte_range()
> is named pfn and typed with u64, but it's not correct (pfn should
> be unsigned long.)

Does this means "the name 'pfn' implies unsigned long, usually. And
this usage is confusing." ?

> This patch introduces special type for pagemap entry and replace
> code with it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> 

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
