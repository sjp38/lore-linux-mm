Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6D61D6B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 10:16:53 -0500 (EST)
Date: Thu, 12 Nov 2009 00:16:49 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH -mmotm 2/3] memcg: cleanup mem_cgroup_move_parent()
Message-Id: <20091112001649.ba228103.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20091111144050.GL3314@balbir.in.ibm.com>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091111103533.c634ff8d.nishimura@mxp.nes.nec.co.jp>
	<20091111103741.f35e9ffe.nishimura@mxp.nes.nec.co.jp>
	<20091111144050.GL3314@balbir.in.ibm.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009 20:10:50 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-11 10:37:41]:
> 
> > mem_cgroup_move_parent() calls try_charge first and cancel_charge on failure.
> > IMHO, charge/uncharge(especially charge) is high cost operation, so we should
> > avoid it as far as possible.
> > 
> 
> But cancel_charge and move_account are not frequent operations, does
> optimizing this give a significant benefit?
> 
I agree they are not called so frequently, so the benefit would not be so big.
But, the number of lines of memcontrol.c decreases a bit by these patches ;)

IMHO, current mem_cgroup_move_parent() is a bit hard to understand, and mem_cgroup_move_account() have redundant codes. So, I cleaned them up.

Moreover, mem_cgroup_cancel_charge(), which I introduced in [1/3], and the new
wrapper function of mem_cgroup_move_account(), which I introduced in this patch,
will be used in my recharge-at-task-move patches and make them more readable.

> Looks good overall
>  
Thank you.


Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
