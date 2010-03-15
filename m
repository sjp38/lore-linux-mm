Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A98A86B01A4
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 01:39:26 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2F5dNZX020531
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Mar 2010 14:39:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0827445DE53
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 14:39:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D6FAB45DE52
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 14:39:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 63772E38003
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 14:39:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D6561DB8016
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 14:39:22 +0900 (JST)
Date: Mon, 15 Mar 2010 14:35:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 03/11] mm: Share the anon_vma ref counts between KSM and
 page migration
Message-Id: <20100315143542.c09d4546.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1268412087-13536-4-git-send-email-mel@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	<1268412087-13536-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010 16:41:19 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> For clarity of review, KSM and page migration have separate refcounts on
> the anon_vma. While clear, this is a waste of memory. This patch gets
> KSM and page migration to share their toys in a spirit of harmony.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
