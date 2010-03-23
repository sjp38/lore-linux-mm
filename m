Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 917CF6B01B6
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 19:59:41 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2NNxceX002824
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Mar 2010 08:59:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 569CC45DE52
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 08:59:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 27ABA45DE51
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 08:59:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0064D1DB803F
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 08:59:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A34F61DB803C
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 08:59:34 +0900 (JST)
Date: Wed, 24 Mar 2010 08:55:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 03/11] mm: Share the anon_vma ref counts between KSM and
 page migration
Message-Id: <20100324085545.333cb7c6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1269347146-7461-4-git-send-email-mel@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010 12:25:38 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> For clarity of review, KSM and page migration have separate refcounts on
> the anon_vma. While clear, this is a waste of memory. This patch gets
> KSM and page migration to share their toys in a spirit of harmony.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
