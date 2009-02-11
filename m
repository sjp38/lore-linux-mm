Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2993D6B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 03:22:52 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1B8Mn30012744
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Feb 2009 17:22:49 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3F4B45DE4E
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 17:22:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7486945DE4F
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 17:22:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5665AE38006
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 17:22:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 07873E38001
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 17:22:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmalloc: Add __get_vm_area_caller()
In-Reply-To: <20090211044854.969CEDDDA9@ozlabs.org>
References: <20090211044854.969CEDDDA9@ozlabs.org>
Message-Id: <20090211171804.7021.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Feb 2009 17:22:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management <linux-mm@kvack.org>, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> We have get_vm_area_caller() and __get_vm_area() but not __get_vm_area_caller()
> 
> On powerpc, I use __get_vm_area() to separate the ranges of addresses given
> to vmalloc vs. ioremap (various good reasons for that) so in order to be
> able to implement the new caller tracking in /proc/vmallocinfo, I need
> a "_caller" variant of it.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

It seems reasonable reason and this patch looks good to me :)
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> I want to put into powerpc-next patches relying into that, so if the
> patch is ok with you guys, can I stick it in powerpc.git ?

hm.
Generally, all MM patch should merge into -mm tree at first.
but I don't think this patch have conflict risk. 

Andrew, What do you think?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
