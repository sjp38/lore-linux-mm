Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 458FD6B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:48:08 -0400 (EDT)
Message-ID: <4BD118E2.7080307@cn.fujitsu.com>
Date: Fri, 23 Apr 2010 11:49:54 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH] memcg rcu lock fix in swap code (Was Re: [BUG]
 an RCU warning in memcg
References: <4BD10D59.9090504@cn.fujitsu.com> <20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 23 Apr 2010 11:00:41 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> with CONFIG_PROVE_RCU=y, I saw this warning, it's because
>> css_id() is not under rcu_read_lock().
>>
> 
> Ok. Thank you for reporting.
> This is ok ? 

Yes, and I did some more simple tests on memcg, no more warning
showed up.

> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
