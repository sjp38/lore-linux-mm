Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DFAC76B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 19:36:06 -0500 (EST)
Date: Thu, 13 Jan 2011 09:28:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] mm: Remove two memset calls in mm/memcontrol.c by using
 the zalloc variants of alloc functions
Message-Id: <20110113092820.811e34ae.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <alpine.LNX.2.00.1101122135070.22297@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1101122135070.22297@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jan 2011 21:39:59 +0100 (CET)
Jesper Juhl <jj@chaosbits.net> wrote:

> We can avoid two calls to memset() in mm/memcontrol.c by using 
> kzalloc_node(), kzalloc & vzalloc().
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
