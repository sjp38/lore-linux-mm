Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CAE308D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 20:54:06 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AAF083EE0B3
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 10:54:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 897C345DE69
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 10:54:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B40C45DE4D
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 10:54:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 594AD1DB803E
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 10:54:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B5441DB803A
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 10:54:04 +0900 (JST)
Date: Tue, 8 Feb 2011 10:47:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mlock: do not munlock pages in __do_fault()
Message-Id: <20110208104757.bc59f502.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1297126056-14322-3-git-send-email-walken@google.com>
References: <1297126056-14322-1-git-send-email-walken@google.com>
	<1297126056-14322-3-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On Mon,  7 Feb 2011 16:47:36 -0800
Michel Lespinasse <walken@google.com> wrote:

> If the page is going to be written to, __do_page needs to break COW.
> However, the old page (before breaking COW) was never mapped mapped into
> the current pte (__do_fault is only called when the pte is not present),
> so vmscan can't have marked the old page as PageMlocked due to being
> mapped in __do_fault's VMA. Therefore, __do_fault() does not need to worry
> about clearing PageMlocked() on the old page.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
