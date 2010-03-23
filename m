Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2A7B86B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 20:22:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2N0M6U6018714
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Mar 2010 09:22:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 645FE45DE52
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 09:22:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4299245DD76
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 09:22:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 24A17E08005
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 09:22:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B0614E08001
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 09:22:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 06/11] Export fragmentation index via /proc/extfrag_index
In-Reply-To: <20100317113326.GD12388@csn.ul.ie>
References: <20100317114321.4C9A.A69D9226@jp.fujitsu.com> <20100317113326.GD12388@csn.ul.ie>
Message-Id: <20100323050910.A473.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Mar 2010 09:22:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > +	/*
> > > +	 * Index is between 0 and 1 so return within 3 decimal places
> > > +	 *
> > > +	 * 0 => allocation would fail due to lack of memory
> > > +	 * 1 => allocation would fail due to fragmentation
> > > +	 */
> > > +	return 1000 - ( (1000+(info->free_pages * 1000 / requested)) / info->free_blocks_total);
> > > +}
> > 
> > Dumb question.
> > your paper (http://portal.acm.org/citation.cfm?id=1375634.1375641) says
> > fragmentation_index = 1 - (TotalFree/SizeRequested)/BlocksFree
> > but your code have extra '1000+'. Why?
> 
> To get an approximation to three decimal places.

Do you mean this is poor man's round up logic?
Why don't you use DIV_ROUND_UP? likes following,

return 1000 - (DIV_ROUND_UP(info->free_pages * 1000 / requested) /  info->free_blocks_total);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
