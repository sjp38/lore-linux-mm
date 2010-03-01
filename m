Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 05B376B0047
	for <linux-mm@kvack.org>; Sun, 28 Feb 2010 20:42:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o211grl3003419
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Mar 2010 10:42:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 693F645DE4D
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 10:42:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 27B4645DE4F
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 10:42:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ED3DD1DB803C
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 10:42:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F9A81DB8041
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 10:42:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Memory management woes - order 1 allocation failures
In-Reply-To: <84144f021002260917q61f7c255rf994425f3a613819@mail.gmail.com>
References: <alpine.DEB.2.00.1002261042020.7719@router.home> <84144f021002260917q61f7c255rf994425f3a613819@mail.gmail.com>
Message-Id: <20100301103546.DD86.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Mar 2010 10:42:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Frans Pop <elendil@planet.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

> AFAICT, even in the worst case, the latter call-site is well below 4K.
> I have no idea of the tty one.

afaik, tty_buffer_request_room() try to expand its buffer size for efficiency. but Its failure
doesn't cause any user visible failure. probably we can mark it as NOWARN.

In worst case, maximum tty buffer size is 64K, it can make allocation failure easily.


Alan, Can you please tell us your mention?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
