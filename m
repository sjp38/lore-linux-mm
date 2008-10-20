Date: Mon, 20 Oct 2008 11:53:10 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH -mm 0/5] mem+swap resource controller(trial patch)
Message-Id: <20081020115310.c9bb3d14.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20081020092409.67d34506.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081020092409.67d34506.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Oct 2008 09:24:09 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 17 Oct 2008 19:48:04 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hi.
> > 
> > I think Kamezawa-san is working on this now, I also made
> > a trial patch based on Kamezawa-san's v2.
> > 
> yes, I'm now rewriting. I'm now considering whether we can implement easier
> protocol or not. But your patch's direction is not far from mine.
> 
> > Unfortunately this patch doesn't work(I'll investigate),
> > but I post it to promote discussion on this topic.
> > 
> What kind of problems ? accounting is not correct ?
> 
I see "scheduling while atomic" bug(or system hangs) when
trying to swap out some pages.

I'm afraid I take a day off today, I don't have enough
log or information.


Sorry,
Daisuke Nishimura.

> 
> > Major changes from v2:
> > - rebased on memcg-update-v7.
> > - add a counter to count real swap usage(# of swap entries).
> > - add arg "use_swap" to try_to_mem_cgroup_pages() and use it sc->may_swap.
> > 
> > 
> > Thanks,
> > Daisuke Nishimura.
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
