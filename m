Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C02416B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 02:01:48 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5461ktJ023676
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Jun 2010 15:01:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 58CDF45DE6F
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 15:01:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2938245DE60
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 15:01:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0ED831DB8037
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 15:01:46 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7E20E38004
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 15:01:42 +0900 (JST)
Date: Fri, 4 Jun 2010 14:57:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
Message-Id: <20100604145723.e16d7fe0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100604092047.7b7d7bb1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100601163627.245D.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006011140110.32024@chino.kir.corp.google.com>
	<20100602225252.F536.A69D9226@jp.fujitsu.com>
	<20100603161030.074d9b98.akpm@linux-foundation.org>
	<20100604085347.80c7b43f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100603170443.011fdf7c.akpm@linux-foundation.org>
	<20100604092047.7b7d7bb1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jun 2010 09:20:47 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 3 Jun 2010 17:04:43 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > Sure, bugfixes should come separately and first.  For a number of
> > reasons:
> > 
> > - people (including the -stable maintainers) might want to backport them
> > 
> > - we might end up not merging the larger, bugfix-including patches at all
> > 
> > - the large bugfix-including patches might blow up and need
> >   reverting.  If we do that, we accidentally revert bugfixes!
> > 
> > Have we identified specifically which bugfixes should be separated out
> > in this fashion?
> > 
> 
> In my personal observation
> 
>  [1/18]  for better behavior under cpuset.
>  [2/18]  for better behavior under cpuset.
>  [3/18]  for better behavior under mempolicy.
>  [4/18]  refactoring.
>  [5/18]  refactoring.
>  [6/18]  clean up.
>  [7/18]  changing the deault sysctl value.
>  [8/18]  completely new logic.
>  [9/18]  completely new logic.
>  [10/18] a supplement for 8,9.
>  [11/18] for better behavior under lowmem oom (disable oom kill)
>  [12/18] clean up
>  [13/18] bugfix for a possible race condition. (I'm not sure about details)
>  [14/18] bugfix
>  [15/18] bugfix
>  [16/18] bugfix
>  [17/18] bugfix
>  [18/18] clean up.
> 
> If distro admins are aggresive, them may backport 1,2,3,7,11 but
> it changes current logic. So, it's distro's decision.
> 

IMHO, without considering HUNKs, the patch order should be

  13,14,15,16,17,1,2,3,7,11,4,5,6,18,12,8,9,10.

bugfix -> patches for things making better -> refactoring -> the new implementation.

David, I have no objections to functions itself. But please start from small
good things. "Refactoring" is good but it tend to make backporting
not-straightforward. So, I think it should be done when there is no known issues.
I think you can do.

Bye,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
