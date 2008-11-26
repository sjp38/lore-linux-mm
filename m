Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAQ0Jjk1027634
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 26 Nov 2008 09:19:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3626B45DE52
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 09:19:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EEFF745DE50
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 09:19:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C4D62E08009
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 09:19:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 634D51DB803A
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 09:19:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] memcg reclaim shouldn't change zone->recent_rotated statics.
In-Reply-To: <20081126001650.280530d0@lxorguk.ukuu.org.uk>
References: <20081126091027.3CA6.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081126001650.280530d0@lxorguk.ukuu.org.uk>
Message-Id: <20081126091808.3CA9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 26 Nov 2008 09:19:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > however, "_p" isn't linux convention.
> > so, I like "is_" or "can_" (or likes somethingelse) prefix :)
> 
> _p is from lisp but Ted did sneak tty_hung_up_p() into the kernel many
> years ago.

Oh, you expose my knowledgeless ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
