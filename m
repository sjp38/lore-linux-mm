Date: Wed, 18 Jun 2008 11:40:57 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [Bad page] trying to free locked page? (Re: [PATCH][RFC] fix
 kernel BUG at mm/migrate.c:719! in 2.6.26-rc5-mm3)
Message-Id: <20080618114057.564564a0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1213727385.8707.53.camel@lts-notebook>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	<20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	<20080617180314.2d1b0efa.kamezawa.hiroyu@jp.fujitsu.com>
	<20080617181527.5bcbbccc.nishimura@mxp.nes.nec.co.jp>
	<1213727385.8707.53.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > > > 
> > > Good catch, and I think your investigation in the last e-mail was correct.
> > > I'd like to dig this...but it seems some kind of big fix is necessary.
> > > Did this happen under page-migraion by cpuset-task-move test ?
> > > 
> > Yes.
> > 
> > I made 2 cpuset directories, run some processes in each cpusets,
> > and run a script like below infinitely to move tasks and migrate pages.
> 
> What processes/tests do you run in each cpuset?
> 

Please see the mail I've just sended to Kosaki-san :)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
