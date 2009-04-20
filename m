Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4B7765F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 23:41:26 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3K3g3na003329
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 20 Apr 2009 12:42:03 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 29B9C45DE53
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:42:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D64D45DE52
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:42:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 035CF1DB8038
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:42:03 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B2F391DB803A
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:42:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my case?
In-Reply-To: <49EBEBC0.8090102@gmail.com>
References: <20090420114236.dda3de34.minchan.kim@barrios-desktop> <49EBEBC0.8090102@gmail.com>
Message-Id: <20090420123510.2503.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 20 Apr 2009 12:42:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > I can't understand your point exactly yet.
> > But what I mean is following as in user mode
> >
> > posix_memalignq(&buffer);
> > mlock(buffer,  buffer_len); 
> >
> >   
> I also wish the VLC use  the mlock,but it does not.If it uses mlock(),
> the pages will be put in LRU_UNEVICETABL LIST.
> 
> Maybe the programmer of VLC thinks: Why i add mlock, for the kernel has the
> gup() which could pin the pages in memory?

more weakness.

mlock() only gurantee the address range is memory-resident, not gurantee to no change 
virtual-physical mappings.

There are different operation.

example, gup() prevent page migration but mlock doesn't.


> > I will not dirty your driver. 
> > Do I miss something ?
> >   
> I did add the Mlock bit to the VMA->vm_flags in my driver before,but I 
> think that's ugly.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
