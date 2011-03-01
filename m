Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 319268D003C
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 03:21:01 -0500 (EST)
Received: by mail-fx0-f41.google.com with SMTP id 5so5869508fxm.14
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 00:20:59 -0800 (PST)
Subject: Re: [PATCH 4/4] net,rcu: don't assume the size of struct rcu_head
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20110301.001638.104075130.davem@davemloft.net>
References: <4D6CA860.3020409@cn.fujitsu.com>
	 <20110301.001638.104075130.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Mar 2011 09:20:55 +0100
Message-ID: <1298967655.2676.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: laijs@cn.fujitsu.com, mingo@elte.hu, paulmck@linux.vnet.ibm.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

Le mardi 01 mars 2011 A  00:16 -0800, David Miller a A(C)crit :
> From: Lai Jiangshan <laijs@cn.fujitsu.com>
> Date: Tue, 01 Mar 2011 16:03:44 +0800
> 
> > 
> > struct dst_entry assumes the size of struct rcu_head as 2 * sizeof(long)
> > and manually adds pads for aligning for "__refcnt".
> > 
> > When the size of struct rcu_head is changed, these manual padding
> > is wrong. Use __attribute__((aligned (64))) instead.
> > 
> > Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> 
> We don't want to use the align if it's going to waste lots of space.
> 
> Instead we want to rearrange the structure so that the alignment comes
> more cheaply.

Oh well, I should have read your answer before sending mine :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
