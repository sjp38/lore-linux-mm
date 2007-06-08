Date: Fri, 8 Jun 2007 16:25:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memory unplug v4 intro [1/6] migration without mm->sem
Message-Id: <20070608162558.b1a8fbc7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0706080019400.29461@schroedinger.engr.sgi.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
	<20070608143844.569c2804.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706072242500.28618@schroedinger.engr.sgi.com>
	<20070608145435.4fa7c9b6.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706072254160.28618@schroedinger.engr.sgi.com>
	<20070608150602.78f07b34.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706072344040.29301@schroedinger.engr.sgi.com>
	<20070608160148.616dae54.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706080019400.29461@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007 00:21:39 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> > But it's not necessary to add anon_vma_hold() in rmap.c, as you pointed out.
> > I'll rewrite them as static func in migrate.c
> 
> I do not think you need anon_vma_hold at all. Neither do you need to add 
> any other function. The presence of the dummy vma while the page is 
> removed and added guarantees that it does not vanish.
> 
Hmm, ok. add extra codes instead of new function.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
