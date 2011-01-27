Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A027A8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 04:55:06 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0B70D3EE0BC
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 18:54:50 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FE8945DE57
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 18:54:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3B2B45DE53
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 18:54:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C0B431DB8040
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 18:54:46 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 821491DB803A
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 18:54:46 +0900 (JST)
Date: Thu, 27 Jan 2011 18:48:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memsw: handle swapaccount kernel parameter correctly
Message-Id: <20110127184827.a8927595.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110127092951.GA8036@tiehlicka.suse.cz>
References: <20110126152158.GA4144@tiehlicka.suse.cz>
	<20110126140618.8e09cd23.akpm@linux-foundation.org>
	<20110127082320.GA15500@tiehlicka.suse.cz>
	<20110127180330.78585085.kamezawa.hiroyu@jp.fujitsu.com>
	<20110127092951.GA8036@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jan 2011 10:29:51 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 27-01-11 18:03:30, KAMEZAWA Hiroyuki wrote:
> > On Thu, 27 Jan 2011 09:23:20 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> [...]
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index db76ef7..cea2be48 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -5013,9 +5013,9 @@ struct cgroup_subsys mem_cgroup_subsys = {
> > >  static int __init enable_swap_account(char *s)
> > >  {
> > >  	/* consider enabled if no parameter or 1 is given */
> > > -	if (!s || !strcmp(s, "1"))
> > > +	if (!(*s) || !strcmp(s, "=1"))
> > >  		really_do_swap_account = 1;
> > > -	else if (!strcmp(s, "0"))
> > > +	else if (!strcmp(s, "=0"))
> > >  		really_do_swap_account = 0;
> > >  	return 1;
> > >  }
> > 
> > Hmm, usual callser of __setup() includes '=' to parameter name, as
> > 
> > mm/hugetlb.c:__setup("hugepages=", hugetlb_nrpages_setup);
> > mm/hugetlb.c:__setup("default_hugepagesz=", hugetlb_default_setup);
> > 
> > How about moving "=" to __setup() ?
> 
> I have considered that as well but then we couldn't use swapaccount
> parameter without any value because the parameter parsing matches the
> whole string. 
> I found it better to have consistent [no]swapaccount with the =0|1
> extension rather than keeping = in the setup like other users.
> 
> Sounds reasonable?

Hmm. ok for this time.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Could you try to write a patch for feature-removal-schedule.txt
and tries to remove noswapaccount and do clean up all ?
(And add warning to noswapaccount will be removed.....in 2.6.40)


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
