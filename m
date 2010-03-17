Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0C0556B00AC
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 22:06:47 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2H26j2I007896
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Mar 2010 11:06:46 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7539C45DE4F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:06:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 42C7D45DE4C
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:06:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FBCA1DB8015
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:06:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BCE8BE0800E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:06:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 03/11] mm: Share the anon_vma ref counts between KSM and page migration
In-Reply-To: <1268412087-13536-4-git-send-email-mel@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-4-git-send-email-mel@csn.ul.ie>
Message-Id: <20100317110611.4C91.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Mar 2010 11:06:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> For clarity of review, KSM and page migration have separate refcounts on
> the anon_vma. While clear, this is a waste of memory. This patch gets
> KSM and page migration to share their toys in a spirit of harmony.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
