Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 28EF98D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 20:12:51 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 81EE33EE0C2
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:12:47 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 65BA145DE98
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:12:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D28E45DE95
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:12:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D1FDE08004
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:12:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 080F1E08003
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:12:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Q] PGPGIN underflow?
In-Reply-To: <4D8C4953.8020808@kernel.dk>
References: <20110324095735.61bfa370.randy.dunlap@oracle.com> <4D8C4953.8020808@kernel.dk>
Message-Id: <20110329091252.C07A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 29 Mar 2011 09:12:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: kosaki.motohiro@jp.fujitsu.com, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> On 2011-03-24 17:57, Randy Dunlap wrote:
> > On Thu, 24 Mar 2011 10:52:54 +0900 (JST) KOSAKI Motohiro wrote:
> > 
> >> Hi all,
> >>
> >> Recently, vmstast show crazy big "bi" value even though the system has
> >> no stress. Is this known issue?
> >>
> >> Thanks.
> > 
> > underflow?  also looks like -3 or -ESRCH.
> > 
> > Adding Jens in case he has any idea about it.
> 
> First question, what does 'recently' mean? In other words, in what
> kernel did you first notice this behaviour?

Thans, Randy, Jens.
I dagged awhile and I've found this is -mm specific and known issue.
It was fixed by Hannes. (ref Message-ID: <20110324125316.GA2310@cmpxchg.org>)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
