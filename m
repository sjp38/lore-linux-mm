Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 54F366B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 20:35:00 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D0s5VY021908
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 13 Jul 2009 09:54:05 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 825B845DE6E
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 09:54:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D53845DE6F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 09:54:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 375451DB8037
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 09:54:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E45CA1DB8041
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 09:54:01 +0900 (JST)
Date: Mon, 13 Jul 2009 09:52:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
Message-Id: <20090713095209.d8b6e566.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A554B54.3080903@embeddedalley.com>
References: <1239660512-25468-1-git-send-email-dan@embeddedalley.com>
	<1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
	<1246998310-16764-2-git-send-email-vbuzov@embeddedalley.com>
	<20090708095616.cdfe8c7c.kamezawa.hiroyu@jp.fujitsu.com>
	<4A554B54.3080903@embeddedalley.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Vladislav D. Buzov" <vbuzov@embeddedalley.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers Mailing List <containers@lists.linux-foundation.org>, Dan Malek <dan@embeddedalley.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 08 Jul 2009 18:43:48 -0700
"Vladislav D. Buzov" <vbuzov@embeddedalley.com> wrote:

> KAMEZAWA Hiroyuki wrote:

> > 2 points.
> >  - Do we have to check this always we account ?
> >   
> What are the options? Every N pages? How to select N?
> 
I think you can reuse Balbir's softlimit event counter. (see v9.)


> > If this is true, "set limit" should be checked to guarantee this.
> > plz allow minus this for avoiding mess.
> Setting the memory controller cgroup limit and the notification
> threshold are two separate operations. There isn't any "mess," just some
> validation testing for reporting back to the source of the request. When
> changing the memory controller limit, we ensure the threshold limit is
> never allowed "negative." At most, the threshold limit will be equal the
> memory controller cgroup limit. Otherwise, the arithmetic and
> conditional tests during the operational part of the software becomes
> more complex, which we don't want.
> 
Hmm, then, plz this interface put under "set_limit_mutex".

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
