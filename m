Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 27C298D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 03:36:16 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BD98D3EE0BD
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:36:07 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A35F845DE4E
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:36:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89E1745DE4D
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:36:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CDEBE08002
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:36:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A8991DB802C
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:36:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/8] Change alloc_pages_vma to pass down the policy node for local policy
In-Reply-To: <1299182391-6061-3-git-send-email-andi@firstfloor.org>
References: <1299182391-6061-1-git-send-email-andi@firstfloor.org> <1299182391-6061-3-git-send-email-andi@firstfloor.org>
Message-Id: <20110307173604.8A07.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Mar 2011 17:36:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

> From: Andi Kleen <ak@linux.intel.com>
> 
> Currently alloc_pages_vma always uses the local node as policy node
> for the LOCAL policy. Pass this node down as an argument instead.
> 
> No behaviour change from this patch, but will be needed for followons.
> 
> Acked-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
