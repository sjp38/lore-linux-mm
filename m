Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1616B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 18:48:41 -0500 (EST)
Date: Tue, 16 Feb 2010 08:44:09 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm] memcg: update memcg_test.txt
Message-Id: <20100216084409.540226e2.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100215072612.GB5612@balbir.in.ibm.com>
References: <20100203110048.6c8f66c4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100215094913.57922cab.nishimura@mxp.nes.nec.co.jp>
	<20100215072612.GB5612@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010 12:56:12 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-02-15 09:49:13]:
> 
> > Update memcg_test.txt to describe how to test the move-charge feature.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  Documentation/cgroups/memcg_test.txt |   22 ++++++++++++++++++++--
> >  1 files changed, 20 insertions(+), 2 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
> > index 72db89e..e011488 100644
> > --- a/Documentation/cgroups/memcg_test.txt
> > +++ b/Documentation/cgroups/memcg_test.txt
> > @@ -1,6 +1,6 @@
> >  Memory Resource Controller(Memcg)  Implementation Memo.
> > -Last Updated: 2009/1/20
> > -Base Kernel Version: based on 2.6.29-rc2.
> > +Last Updated: 2010/2
> > +Base Kernel Version: based on 2.6.33-rc7-mm(candidate for 34).
> > 
> >  Because VM is getting complex (one of reasons is memcg...), memcg's behavior
> >  is complex. This is a document for memcg's internal behavior.
> > @@ -378,3 +378,21 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
> >  	#echo 50M > memory.limit_in_bytes
> >  	#echo 50M > memory.memsw.limit_in_bytes
> >  	run 51M of malloc
> > +
> > + 9.9 Move charges at task migration
> > +	Charges associated with a task can be moved along with task migration.
> > +
> > +	(Shell-A)
> > +	#mkdir /cgroup/A
> > +	#echo $$ >/cgroup/A/tasks
> > +	run some programs which uses some amount of memory in /cgroup/A.
> > +
> > +	(Shell-B)
> > +	#mkdir /cgroup/B
> > +	#echo 1 >/cgroup/B/memory.move_charge_at_immigrate
> > +	#echo "pid of the program running in group A" >/cgroup/B/tasks
> > +
> > +	You can see charges have been moved by reading *.usage_in_bytes or
> > +	memory.stat of both A and B.
> > +	See 8.2 of Documentation/cgroups/memory.txt to see what value should be
> > +	written to move_charge_at_immigrate.
> 
> Looks good to me, I would also try and ping pong task migration with
> move_charges_at_immigrate enabled and check for stability as well.
> 
Thank you. It would be a very useful test.

Regards,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
