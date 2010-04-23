Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CE24E6B020E
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 16:57:17 -0400 (EDT)
Received: from f199130.upc-f.chello.nl ([80.56.199.130] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1O5Pw2-0006jh-8t
	for linux-mm@kvack.org; Fri, 23 Apr 2010 20:57:14 +0000
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <xr93k4rxx6sd.fsf@ninji.mtv.corp.google.com>
References: <1268609202-15581-2-git-send-email-arighi@develer.com>
	 <20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100318162855.GG18054@balbir.in.ibm.com>
	 <20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100319024039.GH18054@balbir.in.ibm.com>
	 <20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	 <xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	 <20100414140523.GC13535@redhat.com>
	 <xr9339yxyepc.fsf@ninji.mtv.corp.google.com>
	 <20100415114022.ef01b704.nishimura@mxp.nes.nec.co.jp>
	 <g2u49b004811004142148i3db9fefaje1f20760426e0c7e@mail.gmail.com>
	 <20100415152104.62593f37.nishimura@mxp.nes.nec.co.jp>
	 <20100415155432.cf1861d9.kamezawa.hiroyu@jp.fujitsu.com>
	 <xr93k4rxx6sd.fsf@ninji.mtv.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 23 Apr 2010 22:57:06 +0200
Message-ID: <1272056226.1821.41.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-04-23 at 13:17 -0700, Greg Thelen wrote:
> +static void mem_cgroup_begin_page_cgroup_reassignment(void)
> +{
> +       VM_BUG_ON(mem_cgroup_account_move_ongoing);
> +       mem_cgroup_account_move_ongoing = true;
> +       synchronize_rcu();
> +} 

btw, you know synchronize_rcu() is _really_ slow?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
