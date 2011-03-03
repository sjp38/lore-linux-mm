Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2BAA08D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 21:39:38 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 12B6C3EE0C0
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:39:35 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E291445DE68
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:39:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C7C7245DD74
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:39:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AF3D81DB803F
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:39:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70E501DB803C
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:39:34 +0900 (JST)
Date: Thu, 3 Mar 2011 11:33:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] Add __GFP_OTHER_NODE flag
Message-Id: <20110303113315.7bf5de3c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299113128-11349-7-git-send-email-andi@firstfloor.org>
References: <1299113128-11349-1-git-send-email-andi@firstfloor.org>
	<1299113128-11349-7-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Wed,  2 Mar 2011 16:45:26 -0800
Andi Kleen <andi@firstfloor.org> wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> Add a new __GFP_OTHER_NODE flag to tell the low level numa statistics
> in zone_statistics() that an allocation is on behalf of another thread.
> This way the local and remote counters can be still correct, even
> when background daemons like khugepaged are changing memory
> mappings.
> 
> This only affects the accounting, but I think it's worth doing that
> right to avoid confusing users.
> 
> I first tried to just pass down the right node, but this required
> a lot of changes to pass down this parameter and at least one
> addition of a 10th argument to a 9 argument function. Using
> the flag is a lot less intrusive.
> 
> Open: should be also used for migration?
> 
> Cc: aarcange@redhat.com
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
