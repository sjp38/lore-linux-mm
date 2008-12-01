Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB19iHI4031458
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Dec 2008 18:44:17 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E7E845DD72
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 18:44:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 408B645DD70
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 18:44:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 27B651DB803E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 18:44:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CED9F1DB803A
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 18:44:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Swappiness fix?
In-Reply-To: <200812010435.41540.gene.heskett@gmail.com>
References: <200812010435.41540.gene.heskett@gmail.com>
Message-Id: <20081201184115.1CC2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Dec 2008 18:44:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gene Heskett <gene.heskett@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

> Greetings;
> 
> Has that patch someone pointed me to made it into -rc6?  I have a bit under 9 
> hours uptime on a 4Gb machine, with a gimp session, email and web browsing, 
> and I see I'm 27 megs into swap.  I do not have the patch now, a drive died.
> However, I may still have the email that contained it, I'll check that.
> 
> That patch, IMO should be fast lane'd to make it to .28.

Could you please try to mmotm?
As far as I know, nobody give Tested-by to the fixing patch.

if you can test it, I'm very glad.
thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
