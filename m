Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A85DC5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 21:39:48 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9M1dkn5007586
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 22 Oct 2010 10:39:46 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78F3B45DE50
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 10:39:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D42945DE4E
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 10:39:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 08C0DE08002
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 10:39:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 92154E08005
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 10:39:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: slub: move slabinfo.c to tools/slub/slabinfo.c
In-Reply-To: <alpine.DEB.2.00.1010211324190.24115@router.home>
References: <20101021111626.e3f214f5.randy.dunlap@oracle.com> <alpine.DEB.2.00.1010211324190.24115@router.home>
Message-Id: <20101022103842.53AC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Oct 2010 10:39:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Randy Dunlap <randy.dunlap@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 21 Oct 2010, Randy Dunlap wrote:
> 
> > Any special build/make rules needed, or just use straight 'gcc slabinfo.c -o slabinfo' ?
> > (as listed in the source file :)
> 
> Just straight.

Now, slabinfo has a lot of user. so few line simple Makefile takes a lot
of help, I think. :)

Anyway, I like this change.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> 
> > Why move only this one source file from Documentation/vm/ ?
> > There are several others there.
> 
> I felt somehow responsible since I placed it there.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
