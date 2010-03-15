Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 496F36B01BC
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 06:00:29 -0400 (EDT)
Date: Mon, 15 Mar 2010 11:00:25 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-ID: <20100315100024.GA1653@linux.develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
 <1268609202-15581-2-git-send-email-arighi@develer.com>
 <20100315090638.ee416d93.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100315090638.ee416d93.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 09:06:38AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 15 Mar 2010 00:26:38 +0100
> Andrea Righi <arighi@develer.com> wrote:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, file-mapped is maintaiend. But more generic update function
> > will be needed for dirty page accounting.
> > 
> > For accountig page status, we have to guarantee lock_page_cgroup()
> > will be never called under tree_lock held.
> > To guarantee that, we use trylock at updating status.
> > By this, we do fuzzy accounting, but in almost all case, it's correct.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Bad patch title...."use trylock for safe accounting in some contexts" ?

OK, sounds better. I just copy & paste the email subject, but the title
was probably related to the old lock_page_cgroup()+irq_disable patch.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
