Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B96A78D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 22:02:13 -0500 (EST)
Received: by wyi11 with SMTP id 11so6831020wyi.14
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 19:02:10 -0800 (PST)
Subject: Re: [PATCH 4/4 V2] net,rcu: don't assume the size of struct
 rcu_head
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4D6DAF86.2000407@cn.fujitsu.com>
References: <4D6CA860.3020409@cn.fujitsu.com>
	 <20110301.001638.104075130.davem@davemloft.net>
	 <4D6CB414.8050107@cn.fujitsu.com> <1298971213.3284.4.camel@edumazet-laptop>
	 <4D6DAF86.2000407@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 02 Mar 2011 04:02:05 +0100
Message-ID: <1299034925.2930.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu, paulmck@linux.vnet.ibm.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

Le mercredi 02 mars 2011 A  10:46 +0800, Lai Jiangshan a A(C)crit :

> Is it the cause of false sharing? I thought that all are rare write(except __refcnt)
> since it is protected by RCU.
> 
> Do you allow me just move the seldom access rcu_head to the end of the structure
> and add pads before __refcnt? I guess it increases about 3% the size of dst_entry.


dst_entry is a base class.

Its included at the beginning of other structs.

Moving rcu_head "at the end" just move it right in the middle of upper
objects as a matter of fact. This might add one cache line miss on
critical network object. A complete audit is needed.

David is doing some changes in this area, so things move fast anyway.

> I accept that I leave this code as is, when I change rcu_head I will
notify you.
> 

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
