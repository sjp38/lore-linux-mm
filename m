Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7906E6B0089
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 03:41:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G8ffr2020924
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Feb 2010 17:41:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E2D0345DE51
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:41:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BBED545DE4E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:41:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A0F31DB803C
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:41:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 080051DB8038
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:41:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 03/12] Export unusable free space index via /proc/pagetypeinfo
In-Reply-To: <20100216083612.GA26086@csn.ul.ie>
References: <20100216152106.72FA.A69D9226@jp.fujitsu.com> <20100216083612.GA26086@csn.ul.ie>
Message-Id: <20100216173832.730F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Feb 2010 17:41:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, Feb 16, 2010 at 04:03:29PM +0900, KOSAKI Motohiro wrote:
> > > Unusuable free space index is a measure of external fragmentation that
> > > takes the allocation size into account. For the most part, the huge page
> > > size will be the size of interest but not necessarily so it is exported
> > > on a per-order and per-zone basis via /proc/pagetypeinfo.
> > 
> > Hmmm..
> > /proc/pagetype have a machine unfriendly format. perhaps, some user have own ugly
> > /proc/pagetype parser. It have a little risk to break userland ABI.
> > 
> 
> It's very low risk. I doubt there are machine parsers of
> /proc/pagetypeinfo because there are very few machine-orientated actions
> that can be taken based on the information. It's more informational for
> a user if they were investigating fragmentation problems.
> 
> > I have dumb question. Why can't we use another file?
> 
> I could. What do you suggest?

I agree it's low risk. but personally I hope fragmentation ABI keep very stable because
I expect some person makes userland compaction daemon. (read fragmentation index
from /proc and write /proc/compact_memory if necessary).
then, if possible, I hope fragmentation info have individual /proc file.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
