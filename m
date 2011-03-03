Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA318D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 21:23:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 91A123EE0C5
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:23:47 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AB5E45DE56
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:23:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64D2B45DE57
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:23:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 58C5DE08002
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:23:47 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 201C2E18001
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:23:47 +0900 (JST)
Date: Thu, 3 Mar 2011 11:17:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/8] Preserve original node for transparent huge page
 copies
Message-Id: <20110303111725.6e29c2da.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299113128-11349-5-git-send-email-andi@firstfloor.org>
References: <1299113128-11349-1-git-send-email-andi@firstfloor.org>
	<1299113128-11349-5-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Wed,  2 Mar 2011 16:45:24 -0800
Andi Kleen <andi@firstfloor.org> wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> This makes a difference for LOCAL policy, where the node cannot
> be determined from the policy itself, but has to be gotten
> from the original page.
> 
> Acked-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
