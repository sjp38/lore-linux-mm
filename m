Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3DA51600363
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 19:56:28 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2HNuPsJ026199
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 18 Mar 2010 08:56:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A7F945DE56
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 08:56:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D7A545DE53
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 08:56:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 12B4C1DB8012
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 08:56:25 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B35D1E08002
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 08:56:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 04/11] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA or memory hot-remove
In-Reply-To: <alpine.DEB.2.00.1003171135390.27268@router.home>
References: <20100317113205.GC12388@csn.ul.ie> <alpine.DEB.2.00.1003171135390.27268@router.home>
Message-Id: <20100318085226.8726.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 18 Mar 2010 08:56:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 17 Mar 2010, Mel Gorman wrote:
> 
> > > If select MIGRATION works, we can remove "depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE"
> > > line from config MIGRATION.
> > >
> >
> > I'm not quite getting why this would be an advantage. COMPACTION
> > requires MIGRATION but conceivable both NUMA and HOTREMOVE can work
> > without it.
> 
> Avoids having to add additional CONFIG_XXX on the page migration "depends"
> line in the future.

Yes, Kconfig mess freqently shot ourself in past days. if we have a chance
to remove unnecessary dependency, we should do. that's my intention of the last mail.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
