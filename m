Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 656846B0055
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:46:19 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n65B9xhC002023
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 5 Jul 2009 20:09:59 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B270E45DE79
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 20:09:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1420345DE6E
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 20:09:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FE131DB803F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 20:09:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A5E731DB8037
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 20:09:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] add per-zone statistics to show_free_areas()
In-Reply-To: <20090705110548.GA1898@localhost>
References: <20090705182259.08F6.A69D9226@jp.fujitsu.com> <20090705110548.GA1898@localhost>
Message-Id: <20090705200757.0911.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  5 Jul 2009 20:09:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Sun, Jul 05, 2009 at 05:23:35PM +0800, KOSAKI Motohiro wrote:
> > Subject: [PATCH] add per-zone statistics to show_free_areas()
> > 
> > Currently, show_free_area() mainly display system memory usage. but it
> > doesn't display per-zone memory usage information.
> > 
> > However, if DMA zone OOM occur, Administrator definitely need to know
> > per-zone memory usage information.
> 
> DMA zone is normally lowmem-reserved. But I think the numbers still
> make sense for DMA32.
> 
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Yes, x86_64 have DMA and DMA32, but almost 64-bit architecture have
2 or 4GB "DMA" zone.
Then, I wrote the patch description by generic name.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
