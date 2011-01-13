Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 45DF46B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 19:14:46 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4190F3EE0B5
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 09:14:44 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 24F8645DE6C
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 09:14:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E9C5F45DE55
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 09:14:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D86BC1DB8047
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 09:14:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A05DA1DB803E
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 09:14:43 +0900 (JST)
Date: Thu, 13 Jan 2011 09:08:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: Remove two memset calls in mm/memcontrol.c by using
 the zalloc variants of alloc functions
Message-Id: <20110113090830.3bca41ee.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LNX.2.00.1101122135070.22297@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1101122135070.22297@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jan 2011 21:39:59 +0100 (CET)
Jesper Juhl <jj@chaosbits.net> wrote:

> We can avoid two calls to memset() in mm/memcontrol.c by using 
> kzalloc_node(), kzalloc & vzalloc().
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
