Date: Sat, 4 Oct 2008 00:25:30 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH 3/6] memcg: charge-commit-cancel protocl
Message-Id: <20081004002530.776d4592.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <2964081.1223046917168.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081003190509.e33a3843.nishimura@mxp.nes.nec.co.jp>
	<20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
	<20081001165734.e484cfe4.kamezawa.hiroyu@jp.fujitsu.com>
	<2964081.1223046917168.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Sat, 4 Oct 2008 00:15:17 +0900 (JST)
kamezawa.hiroyu@jp.fujitsu.com wrote:

> ----- Original Message -----
> >> precharge/commit/cancel can be used for other places,
> >>  - shmem, (and other places need precharge.)
> >>  - move_account(force_empty) etc...
> >> we'll revisit later.
> >> 
> >> Changelog v5 -> v6:
> >>  - added newpage_charge() and migrate_fixup().
> >>  - renamed  functions for swap-in from "swap" to "swapin"
> >>  - add more precise description.
> >> 
> >
> >I don't have any objection to this direction now, but I have one quiestion.
> >
> >Does mem_cgroup_charge_migrate_fixup need to charge a newpage,
> >while mem_cgroup_prepare_migration has charged it already?
> In migration-is-failed case, we have to charge *old page* here.
> 
Ah... you are right.
Sorry for noise.


Daisuke Nishimura.

> >
> >I agree adding I/F would be good for future, but I think
> >mem_cgroup_charge_migration_fixup can be no-op function for now.
> >
> Hmm, handling failure case in explicit way may be better. Ok,
> I'll try some.
> 
> Thanks,
> -Kame
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
