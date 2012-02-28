Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 5A4576B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 18:56:09 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6CCC23EE0BD
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 08:56:07 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DC5545DE57
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 08:56:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 33F3B45DE54
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 08:56:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F3C61DB8042
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 08:56:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C6F661DB803B
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 08:56:06 +0900 (JST)
Date: Wed, 29 Feb 2012 08:54:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 08/10] memcg: Add
 CONFIG_CGROUP_MEM_RES_CTLR_KMEM_ACCT_ROOT.
Message-Id: <20120229085416.447e6fd4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CABCjUKAUQZuW9hFeMJ1Oh=0UeS2Ffx4-vHpnaGpjOFu+3KktAA@mail.gmail.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-9-git-send-email-ssouhlal@FreeBSD.org>
	<4F4CD7E7.1070901@parallels.com>
	<CABCjUKAUQZuW9hFeMJ1Oh=0UeS2Ffx4-vHpnaGpjOFu+3KktAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: Glauber Costa <glommer@parallels.com>, Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Tue, 28 Feb 2012 15:36:27 -0800
Suleiman Souhlal <suleiman@google.com> wrote:

> On Tue, Feb 28, 2012 at 5:34 AM, Glauber Costa <glommer@parallels.com> wrote:
> > On 02/27/2012 07:58 PM, Suleiman Souhlal wrote:
> >>
> >> This config option dictates whether or not kernel memory in the
> >> root cgroup should be accounted.
> >>
> >> This may be useful in an environment where everything is supposed to be
> >> in a cgroup and accounted for. Large amounts of kernel memory in the
> >> root cgroup would indicate problems with memory isolation or accounting.
> >
> >
> > I don't like accounting this stuff to the root memory cgroup. This causes
> > overhead for everybody, including people who couldn't care less about memcg.
> >
> > If it were up to me, we would simply not account it, and end of story.
> >
> > However, if this is terribly important for you, I think you need to at
> > least make it possible to enable it at runtime, and default it to disabled.
> 
> Yes, that is why I made it a config option. If the config option is
> disabled, that memory does not get accounted at all.
> 
> Making it configurable at runtime is not ideal, because we would
> prefer slab memory that was allocated before cgroups are created to
> still be counted toward root.
> 

I never like to do accounting in root cgroup.
If you want to do this, add config option to account _all_ memory in the root.
Accounting only slab seems very dirty hack.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
