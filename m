Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D327D6B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 12:56:54 -0500 (EST)
Date: Thu, 18 Nov 2010 09:52:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Make swap accounting default behavior configurable v4
Message-Id: <20101118095247.2445b092.akpm@linux-foundation.org>
In-Reply-To: <20101118102349.GF15928@tiehlicka.suse.cz>
References: <20101116101726.GA21296@tiehlicka.suse.cz>
	<20101116124615.978ed940.akpm@linux-foundation.org>
	<20101117092339.1b7c2d6d.nishimura@mxp.nes.nec.co.jp>
	<20101116171225.274019cf.akpm@linux-foundation.org>
	<20101117122801.e9850acf.nishimura@mxp.nes.nec.co.jp>
	<20101118082332.GB15928@tiehlicka.suse.cz>
	<20101118174654.8fa69aca.nishimura@mxp.nes.nec.co.jp>
	<20101118175334.be00c8f2.kamezawa.hiroyu@jp.fujitsu.com>
	<20101118095607.GD15928@tiehlicka.suse.cz>
	<20101118191427.fd86db5c.nishimura@mxp.nes.nec.co.jp>
	<20101118102349.GF15928@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010 11:23:49 +0100 Michal Hocko <mhocko@suse.cz> wrote:

> > I'm sorry again and again, but I think removing "noswapaccount" completely
> > would be better, as Andrew said first:
> 
> I read the above Andrew's statement that we really should stick with the
> old parameter.

yup.  We shouldn't remove the existing parameter, which people might be
using already.

> > > So we have swapaccount and noswapaccount.  Ho hum, "swapaccount=[1|0]"
> > > would have been better.

What I meant was that it was a mistake to add the "noswapaccount" in
the first place.  We should have made it "swapaccount=0", because that
would leave open the later option of reversing the default, and
enabling "swapaccount=1".

It also give us the option of adding "swapaccount=2"!  Perhaps to
enable alternative swap accounting behaviour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
