Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1029C6B01F2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 05:18:21 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7J9IJSZ004351
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Aug 2010 18:18:19 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F36D45DE57
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 18:18:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F310345DE4E
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 18:18:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DE0F91DB803C
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 18:18:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EB8B1DB803A
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 18:18:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [TESTCASE] Clean pages clogging the VM
In-Reply-To: <20100818141308.GD1779@cmpxchg.org>
References: <20100817195001.GA18817@linux.intel.com> <20100818141308.GD1779@cmpxchg.org>
Message-Id: <20100819181447.5FBA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Aug 2010 18:18:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Hi Matthew,
> 
> On Tue, Aug 17, 2010 at 03:50:01PM -0400, Matthew Wilcox wrote:
> > 
> > No comment on this?  Was it just that I posted it during the VM summit?
> 
> I have not forgotten about it.  I just have a hard time reproducing
> those extreme stalls you observed.

me too.
I never forgot this one, but...

I'll trying this again at next week.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
