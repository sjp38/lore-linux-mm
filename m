Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DE66F6B004D
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 02:21:49 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J6LkiW025032
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 19 Mar 2010 15:21:46 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C670845DE55
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A546145DE51
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 88CEF1DB803F
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A60B1DB803C
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped anonymous pages
In-Reply-To: <20100318111436.GK12388@csn.ul.ie>
References: <20100318094720.872F.A69D9226@jp.fujitsu.com> <20100318111436.GK12388@csn.ul.ie>
Message-Id: <20100319152103.876F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 19 Mar 2010 15:21:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > then, this logic depend on SLAB_DESTROY_BY_RCU, not refcount.
> > So, I think we don't need your [1/11] patch.
> > 
> > Am I missing something?
> > 
> 
> The refcount is still needed. The anon_vma might be valid, but the
> refcount is what ensures that the anon_vma is not freed and reused.

please please why do we need both mechanism. now cristoph is very busy and I am
de fact reviewer of page migration and mempolicy code. I really hope to understand
your patch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
