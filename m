Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 71A188D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 03:03:59 -0500 (EST)
Date: Fri, 28 Jan 2011 09:03:52 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memsw: Deprecate noswapaccount kernel parameter and
 schedule it for removal
Message-ID: <20110128080352.GA5914@tiehlicka.suse.cz>
References: <20110126152158.GA4144@tiehlicka.suse.cz>
 <20110126140618.8e09cd23.akpm@linux-foundation.org>
 <20110127082320.GA15500@tiehlicka.suse.cz>
 <20110127180330.78585085.kamezawa.hiroyu@jp.fujitsu.com>
 <20110127092951.GA8036@tiehlicka.suse.cz>
 <20110127184827.a8927595.kamezawa.hiroyu@jp.fujitsu.com>
 <20110127104759.GA4301@tiehlicka.suse.cz>
 <20110128083703.a154050b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110128083703.a154050b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri 28-01-11 08:37:03, KAMEZAWA Hiroyuki wrote:
> On Thu, 27 Jan 2011 11:47:59 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 27-01-11 18:48:27, KAMEZAWA Hiroyuki wrote:
> > > Could you try to write a patch for feature-removal-schedule.txt
> > > and tries to remove noswapaccount and do clean up all ?
> > > (And add warning to noswapaccount will be removed.....in 2.6.40)
> > 
> > Sure, no problem. What do you think about the following patch?
> > ---
> > From a597421909a3291886345565c73102117a52301e Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Thu, 27 Jan 2011 11:41:01 +0100
> > Subject: [PATCH] memsw: Deprecate noswapaccount kernel parameter and schedule it for removal
> > 
> > noswapaccount couldn't be used to control memsw for both on/off cases so
> > we have added swapaccount[=0|1] parameter. This way we can turn the
> > feature in two ways noswapaccount resp. swapaccount=0. We have kept the
> > original noswapaccount but I think we should remove it after some time
> > as it just makes more command line parameters without any advantages and
> > also the code to handle parameters is uglier if we want both parameters.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > Requested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Nice!. Thank you.
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks

> 
> Maybe other discussion as 2.6.40 is too early or some may happen.
> But Ack from me, at least.

Sure.

Just for record here is the patch to remove and cleanup. I can split it
into 2 patches (one for removal and the other for the cleanup) but this
can be done later as well.
---
