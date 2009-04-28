Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 752956B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 04:03:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S83AIH014137
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 28 Apr 2009 17:03:11 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ADCEB45DD79
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:03:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C37C45DE51
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:03:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7302C1DB803C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:03:10 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 271281DB803B
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:03:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Swappiness vs. mmap() and interactive response
In-Reply-To: <1240904919.7620.73.camel@twins>
References: <20090428143019.EBBF.A69D9226@jp.fujitsu.com> <1240904919.7620.73.camel@twins>
Message-Id: <20090428170214.EBD8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 17:03:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > 1. please post your /proc/meminfo
> > 2. Do above copy make tons swap-out? IOW your disk read much faster than write?
> > 3. cache limitation of memcgroup solve this problem?
> > 4. Which disk have your /bin and /usr/bin?
> > 
> 
> FWIW I fundamentally object to 3 as being a solution.

Yes, I also think so.


> I still think the idea of read-ahead driven drop-behind is a good one,
> alas last time we brought that up people thought differently.

hmm.
sorry, I can't recall this patch. do you have any pointer or url?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
