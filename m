Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B8AB86B01AC
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 07:22:15 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2PBMCgs030004
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 25 Mar 2010 20:22:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DBAE545DE4F
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 20:22:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B5AAA45DE4E
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 20:22:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8979BEF8004
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 20:22:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F274E38007
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 20:22:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
In-Reply-To: <20100319101016.GS12388@csn.ul.ie>
References: <20100319152516.8778.A69D9226@jp.fujitsu.com> <20100319101016.GS12388@csn.ul.ie>
Message-Id: <20100325202145.6C92.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Mar 2010 20:22:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Viewpoint 5. end user surprising
> > 
> > lumpy reclaim can makes swap-out even though the system have lots free
> > memory. end users very surprised it and they can think it is bug.
> > 
> > Also, this swap activity easyly confuse that an administrator decide when
> > install more memory into the system.
> > 
> 
> Compaction in this case is a lot less surprising. If there is enough free
> memory, compaction will trigger automatically without any reclaim.

I fully agree this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
