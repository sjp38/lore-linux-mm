Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C4BF88D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 21:37:06 -0500 (EST)
Date: Mon, 15 Nov 2010 11:31:55 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC PATCH] Make swap accounting default behavior configurable
 v2
Message-Id: <20101115113155.83361d21.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101115020330.GB9882@balbir.in.ibm.com>
References: <20101110125154.GC5867@tiehlicka.suse.cz>
	<20101111094613.eab2ec0b.nishimura@mxp.nes.nec.co.jp>
	<20101111093155.GA20630@tiehlicka.suse.cz>
	<20101112094118.b02b669f.nishimura@mxp.nes.nec.co.jp>
	<20101112083103.GB7285@tiehlicka.suse.cz>
	<20101115101335.8880fd87.nishimura@mxp.nes.nec.co.jp>
	<20101115020330.GB9882@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010 07:33:30 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-11-15 10:13:35]:
> 
> Thanks Nishimura-San
> 
> It seems like the motivation for the patch is to allow distros to
> enable memory cgroups and swap control, but to have swap control
> turned off by default (because we provide default on today)
>  - is my understanding correct?
> 
I think you're right.

This patch make the default behavior configurable by .config and let users
turn swap control on even if it's disabled by .config.
It will give distros and users wider choice.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
