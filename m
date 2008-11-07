Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA71DLrr028025
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 Nov 2008 10:13:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B39B245DD7D
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:13:21 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 821F145DD78
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:13:21 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B1831DB803C
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:13:21 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 14EF41DB803A
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:13:21 +0900 (JST)
Date: Fri, 7 Nov 2008 10:12:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 7/6] memcg: add atribute (for change bahavior
 ofrmdir)
Message-Id: <20081107101245.2ac46e75.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6941.10.75.179.62.1225981828.squirrel@webmail-b.css.fujitsu.com>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
	<49129493.9070103@linux.vnet.ibm.com>
	<20081106194153.220157ec.kamezawa.hiroyu@jp.fujitsu.com>
	<4912F53A.2070407@linux.vnet.ibm.com>
	<6941.10.75.179.62.1225981828.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Nov 2008 23:30:28 +0900 (JST)
"KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Balbir Singh said:
> > KAMEZAWA Hiroyuki wrote:
> >> BTW, cost of movement itself is not far from cost for force_empty.
> >>
> >> If you can't find why "forget" is bad, please consider one more day.
> >
> > The attributes seem quite reasonable, I've taken a quick look, not done a
> > full
> > review or test.
> >
> Thanks, I'll go ahead in this direction.
> 
It seems Andrew picked account_move patch into his queue. I'll post this as
add-on to mmotm, in the next week. patch-for-test can be posted in hours if
I work well...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
