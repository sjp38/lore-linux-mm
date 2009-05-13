Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7306B00BE
	for <linux-mm@kvack.org>; Wed, 13 May 2009 00:15:01 -0400 (EDT)
Message-id: <isapiwc.d14e3c2a.4d44.4a0a4870.109c6.78@mail.jp.nec.com>
In-Reply-To: <20090513125558.57be0db6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
 <20090512140648.0974cb10.nishimura@mxp.nes.nec.co.jp>
 <20090512160901.8a6c5f64.kamezawa.hiroyu@jp.fujitsu.com>
 <20090512170007.ad7f5c7b.nishimura@mxp.nes.nec.co.jp>
 <20090512171356.3d3a7554.kamezawa.hiroyu@jp.fujitsu.com>
 <20090512195823.15c5cb80.d-nishimura@mtf.biglobe.ne.jp>
 <20090513085949.3c4b7b97.kamezawa.hiroyu@jp.fujitsu.com>
 <20090513092828.cbaa5a76.nishimura@mxp.nes.nec.co.jp>
 <20090513093250.7803d3d0.kamezawa.hiroyu@jp.fujitsu.com>
 <20090513125558.57be0db6.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 May 2009 13:11:28 +0900
From: nishimura@mxp.nes.nec.co.jp
Subject: Re: [PATCH][BUGFIX] memcg: fix for deadlock between
 lock_page_cgroup and mapping tree_lock
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 13 May 2009 09:32:50 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> On Wed, 13 May 2009 09:28:28 +0900
>> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>> 
>> > On Wed, 13 May 2009 08:59:49 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > On Tue, 12 May 2009 19:58:23 +0900
>> > > Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:
>> > > 
>> > > > On Tue, 12 May 2009 17:13:56 +0900
>> > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > > 
>> > > > > On Tue, 12 May 2009 17:00:07 +0900
>> > > > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>> > > > > > hmm, I see.
>> > > > > > cache_charge is outside of tree_lock, so moving uncharge would make sense.
>> > > > > > IMHO, we should make the period of spinlock as small as possible,
>> > > > > > and charge/uncharge of pagecache/swapcache is protected by page lock, not tree_lock.
>> > > > > > 
>> > > > > How about this ?
>> > > > Looks good conceptually, but it cannot be built :)
>> > > > 
>> > > > It needs a fix like this.
>> > > > Passed build test with enabling/disabling both CONFIG_MEM_RES_CTLR
>> > > > and CONFIG_SWAP.
>> > > > 
>> > > ok, will update. can I add you Signed-off-by on the patch ?
>> > > 
>> > Sure.
>> > 
>> > 	Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> > 
>> > The patch(with my fix applied) seems to work fine, I need run it
>> > for more long time though.
>> > 
>> Ok, I'll treat this as an independent issue, not as "4/4".
>> 
> Could you merge mine and yours and send it to Andrew ?
> I think this is a fix for dead-lock and priority is very high.
> I foumd my system broken and installing the whole system again, now.
> So, I can't post patch today.
> 
Okey.

I'll post it soon.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
