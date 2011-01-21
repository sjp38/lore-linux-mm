Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7D0528D0069
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 22:21:42 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D084A3EE0AE
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 12:21:39 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8AAA45DE4E
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 12:21:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D65245DD74
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 12:21:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DCC21DB803B
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 12:21:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 59FD71DB8038
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 12:21:39 +0900 (JST)
Date: Fri, 21 Jan 2011 12:15:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: ksm/thp/memcg bug
Message-Id: <20110121121524.b7957dce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1949676939.98607.1295579559013.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
References: <1607793457.82870.1295506273461.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	<1949676939.98607.1295579559013.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jan 2011 22:12:39 -0500 (EST)
CAI Qian <caiqian@redhat.com> wrote:

> 
> > > Or apply pathces I sent ? (As Nishimura-san pointed out.)
> > I'll try them.
> After applied those patches, the problem goes away.
> 

Great! thank you!

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
