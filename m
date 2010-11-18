Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 976176B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 04:56:17 -0500 (EST)
Date: Thu, 18 Nov 2010 10:56:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Make swap accounting default behavior configurable v4
Message-ID: <20101118095607.GD15928@tiehlicka.suse.cz>
References: <20101116101726.GA21296@tiehlicka.suse.cz>
 <20101116124615.978ed940.akpm@linux-foundation.org>
 <20101117092339.1b7c2d6d.nishimura@mxp.nes.nec.co.jp>
 <20101116171225.274019cf.akpm@linux-foundation.org>
 <20101117122801.e9850acf.nishimura@mxp.nes.nec.co.jp>
 <20101118082332.GB15928@tiehlicka.suse.cz>
 <20101118174654.8fa69aca.nishimura@mxp.nes.nec.co.jp>
 <20101118175334.be00c8f2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118175334.be00c8f2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, stable@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu 18-11-10 17:53:34, KAMEZAWA Hiroyuki wrote:
> On Thu, 18 Nov 2010 17:46:54 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Thu, 18 Nov 2010 09:23:32 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Wed 17-11-10 12:28:01, Daisuke Nishimura wrote:
> > > > On Tue, 16 Nov 2010 17:12:25 -0800
> > > > Andrew Morton <akpm@linux-foundation.org> wrote:
[...]
> > > > > Yes, we're stuck with the old one now.
> > > > > 
> > > > > But we should note that "foo=[0|1]" is superior to "foo" and "nofoo". 
> > > > > Even if we didn't initially intend to add "nofoo".
> > > > > 
> > > > I see.
> > > > 
> > > > Michal-san, could you update your patch to use "swapaccount=[1|0]" ?
> > > 
> > > I have noticed that Andrew has already taken the last version of the
> > > patch for -mm tree. Should I still rework it to change swapaccount to
> > > swapaccount=0|1 resp. true|false?
> > > 
> > It's usual to update a patch into more sophisticated one while it is in -mm tree.
> > So, I think you'd better to do it(btw, I prefer 0|1 to true|false.
> > Reading kernel-parameters.txt, 0|1 is more commonly used.).
> > 
> 
> I vote for 0|1

Changes since v3:
* add 0|1 parameter values handling

Changes since v2:
* put the new parameter description to the proper (alphabetically
* sorted)
  place in Documentation/kernel-parameters.txt
  
Changes since v1:
* do not remove noswapaccount parameter and add swapaccount parameter
* instead
* Documentation/kernel-parameters.txt updated)

--- 
