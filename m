Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA8D8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 00:40:19 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D671A3EE0B6
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:40:15 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BEA7245DD74
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:40:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A36CF45DE67
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:40:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 96F891DB803A
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:40:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 640BF1DB802C
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:40:15 +0900 (JST)
Date: Wed, 23 Mar 2011 13:33:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove unused zone_idx variable from
 set_migratetype_isolate
Message-Id: <20110323133350.f6bbcebd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110322112647.GA5086@swordfish.minsk.epam.com>
References: <20110322112647.GA5086@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 22 Mar 2011 13:26:47 +0200
Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:

> mm: remove unused variable zone_idx and zone_idx call from set_migratetype_isolate
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
