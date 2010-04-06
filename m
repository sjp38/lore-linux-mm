Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 109136B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 02:58:39 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o366wa54025091
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 6 Apr 2010 15:58:36 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EB68545DE52
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 15:58:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FB7F45DE4F
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 15:58:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 85E9D1DB803F
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 15:58:35 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 383241DB803C
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 15:58:35 +0900 (JST)
Date: Tue, 6 Apr 2010 15:54:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of
 PageSwapCache pages
Message-Id: <20100406155443.31053365.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1270224168-14775-15-git-send-email-mel@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
	<1270224168-14775-15-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  2 Apr 2010 17:02:48 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> PageAnon pages that are unmapped may or may not have an anon_vma so are
> not currently migrated. However, a swap cache page can be migrated and
> fits this description. This patch identifies page swap caches and allows
> them to be migrated but ensures that no attempt to made to remap the pages
> would would potentially try to access an already freed anon_vma.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Seems nice to me.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
