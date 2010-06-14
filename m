Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5F7AA6B01B4
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 03:54:16 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5E7sEKQ019784
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 14 Jun 2010 16:54:14 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DFB5245DE50
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:54:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B1CC145DE4E
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:54:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 902211DB803F
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:54:13 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 477391DB8038
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:54:13 +0900 (JST)
Date: Mon, 14 Jun 2010 16:49:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] Linux/Guest unmapped page cache control
Message-Id: <20100614164952.529e081a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100614073646.GS5191@balbir.in.ibm.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	<20100608155146.3749.67837.sendpatchset@L34Z31A.ibm.com>
	<20100613183145.GM5191@balbir.in.ibm.com>
	<20100614092819.cb7515a5.kamezawa.hiroyu@jp.fujitsu.com>
	<20100614064955.GR5191@balbir.in.ibm.com>
	<20100614160021.7febbdb2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100614073646.GS5191@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kvm <kvm@vger.kernel.org>, Avi Kivity <avi@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jun 2010 13:06:46 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
 
> > It sounds that what you want is to improve performance etc. but to make it
> > easy sizing the system and to help admins. Right ?
> >
> 
> Right, to allow freeing up of using double the memory to cache data.
>  
Oh, sorry. ask again..

It sounds that what you want is _not_ to improve performance etc. but to make it
...

?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
