Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2DEC08D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 18:43:12 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8A06C3EE0B3
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 08:43:09 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 717BE45DE55
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 08:43:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 54BE545DE4E
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 08:43:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 48B041DB803E
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 08:43:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FBF71DB8038
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 08:43:09 +0900 (JST)
Date: Fri, 28 Jan 2011 08:37:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memsw: Deprecate noswapaccount kernel parameter and
 schedule it for removal
Message-Id: <20110128083703.a154050b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110127104759.GA4301@tiehlicka.suse.cz>
References: <20110126152158.GA4144@tiehlicka.suse.cz>
	<20110126140618.8e09cd23.akpm@linux-foundation.org>
	<20110127082320.GA15500@tiehlicka.suse.cz>
	<20110127180330.78585085.kamezawa.hiroyu@jp.fujitsu.com>
	<20110127092951.GA8036@tiehlicka.suse.cz>
	<20110127184827.a8927595.kamezawa.hiroyu@jp.fujitsu.com>
	<20110127104759.GA4301@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jan 2011 11:47:59 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 27-01-11 18:48:27, KAMEZAWA Hiroyuki wrote:
> > Could you try to write a patch for feature-removal-schedule.txt
> > and tries to remove noswapaccount and do clean up all ?
> > (And add warning to noswapaccount will be removed.....in 2.6.40)
> 
> Sure, no problem. What do you think about the following patch?
> ---
> From a597421909a3291886345565c73102117a52301e Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 27 Jan 2011 11:41:01 +0100
> Subject: [PATCH] memsw: Deprecate noswapaccount kernel parameter and schedule it for removal
> 
> noswapaccount couldn't be used to control memsw for both on/off cases so
> we have added swapaccount[=0|1] parameter. This way we can turn the
> feature in two ways noswapaccount resp. swapaccount=0. We have kept the
> original noswapaccount but I think we should remove it after some time
> as it just makes more command line parameters without any advantages and
> also the code to handle parameters is uglier if we want both parameters.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Requested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Nice!. Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Maybe other discussion as 2.6.40 is too early or some may happen.
But Ack from me, at least.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
