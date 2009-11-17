Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 580AC6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 07:24:28 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAHCOPMJ007345
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 21:24:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1895F45DE52
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 21:24:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EF0EB45DE4E
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 21:24:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D08EB1DB8037
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 21:24:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 86863E08002
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 21:24:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] Kill PF_MEMALLOC abuse
In-Reply-To: <20091117102701.GA16472@infradead.org>
References: <20091117192232.3DF9.A69D9226@jp.fujitsu.com> <20091117102701.GA16472@infradead.org>
Message-Id: <20091117212327.3E08.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 21:24:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, Nov 17, 2009 at 07:24:42PM +0900, KOSAKI Motohiro wrote:
> > if xfsbufd doesn't only write out dirty data but also drop page,
> > I agree you. 
> 
> It then drops the reference to the buffer which drops references to the
> pages, which often are the last references, yes.

I though it is not typical case. Am I wrong?
if so, I'm sorry. I'm not XFS expert.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
