Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 405EA6B03F1
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 20:33:48 -0400 (EDT)
Date: Tue, 24 Aug 2010 09:19:22 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 4/5] memcg: lockless update of file_mapped
Message-Id: <20100824091922.ae133d72.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100824084916.078d6a82.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820190256.531af759.kamezawa.hiroyu@jp.fujitsu.com>
	<20100823175015.8d834645.nishimura@mxp.nes.nec.co.jp>
	<20100824084916.078d6a82.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 08:49:16 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 23 Aug 2010 17:50:15 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch looks good to me, but I have one question.
> > 
> > Why do we need to acquire sc.lock inside mem_cgroup_(start|end)_move() ?
> > These functions doesn't access mc.*.
> > 
> 
> just reusing a lock to update status. If you don't like, I'll add a new lock.
> 
I see. I think it would be enough just to add some comments about it.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
