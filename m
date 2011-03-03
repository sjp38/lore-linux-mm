Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D22B8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 21:18:43 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0AFA43EE0BC
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:18:41 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E2CD645DE59
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:18:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C840345DE56
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:18:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B24111DB8049
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:18:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 772CCE38001
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:18:40 +0900 (JST)
Date: Thu, 3 Mar 2011 11:12:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/8] Fix interleaving for transparent hugepages v2
Message-Id: <20110303111220.cae43e8e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299113128-11349-2-git-send-email-andi@firstfloor.org>
References: <1299113128-11349-1-git-send-email-andi@firstfloor.org>
	<1299113128-11349-2-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Wed,  2 Mar 2011 16:45:21 -0800
Andi Kleen <andi@firstfloor.org> wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> Bugfix, independent from the rest of the series.
> 
> The THP code didn't pass the correct interleaving shift to the memory
> policy code. Fix this here by adjusting for the order.
> 
> v2: Use + (thanks Christoph)
> Acked-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
