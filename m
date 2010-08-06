Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CF8CB6B02A7
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 20:16:52 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o760J1UD021717
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 6 Aug 2010 09:19:02 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FE3E45DE6E
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 09:19:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DA4245DE60
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 09:19:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 682021DB8040
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 09:19:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 25B451DB803B
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 09:19:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] writeback: Adding pages_dirtied and  pages_entered_writeback
In-Reply-To: <AANLkTimD4jkkPpnhQhR+OF=6=dWV2dJj4M_DGfAmHgRQ@mail.gmail.com>
References: <20100806084928.31DE.A69D9226@jp.fujitsu.com> <AANLkTimD4jkkPpnhQhR+OF=6=dWV2dJj4M_DGfAmHgRQ@mail.gmail.com>
Message-Id: <20100806091548.31ED.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  6 Aug 2010 09:18:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

> On Thu, Aug 5, 2010 at 4:56 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > /proc/vmstat already have both.
> >
> > cat /proc/vmstat |grep nr_dirty
> > cat /proc/vmstat |grep nr_writeback
> >
> > Also, /sys/devices/system/node/node0/meminfo show per-node stat.
> >
> > Perhaps, I'm missing your point.
> 
> These only show the number of dirty pages present in the system at the
> point they are queried.
> The counter I am trying to add are increasing over time. They allow
> developers to see rates of pages being dirtied and entering writeback.
> Which is very helpful.

Usually administrators get the data two times and subtract them. Isn't it sufficient?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
