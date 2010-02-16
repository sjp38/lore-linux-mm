Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 481D66B0098
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 03:49:24 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G8nMMj011766
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Feb 2010 17:49:22 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D5D9345DE54
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:49:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B526945DE51
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:49:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 986601DB803A
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:49:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E10CE08004
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:49:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 04/12] Export fragmentation index via /proc/pagetypeinfo
In-Reply-To: <20100216084113.GB26086@csn.ul.ie>
References: <20100216160518.7303.A69D9226@jp.fujitsu.com> <20100216084113.GB26086@csn.ul.ie>
Message-Id: <20100216174749.7312.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Feb 2010 17:49:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Dumb question. I haven't understand why this calculation represent
> > fragmentation index. Do this have theorical background? if yes, can you
> > please tell me the pointer?
> > 
> 
> Yes, there is a theoritical background. It's mostly described in
> 
> http://portal.acm.org/citation.cfm?id=1375634.1375641
> 
> I have a more updated version but it's not published unfortunately.

ok, thanks. I stop to rush dumb question and read it first. I'll resume rest reviewing
few days after.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
