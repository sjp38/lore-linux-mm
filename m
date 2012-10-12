Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id D08FE6B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 14:54:29 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so3904646oag.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 11:54:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121012125708.GJ10110@dhcp22.suse.cz>
References: <20121012125708.GJ10110@dhcp22.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 12 Oct 2012 14:54:08 -0400
Message-ID: <CAHGf_=rhjUQieH6sqqbt0ST6cbsTYLnZtwizKObBWV6w3Mff4g@mail.gmail.com>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Oct 12, 2012 at 8:57 AM, Michal Hocko <mhocko@suse.cz> wrote:
> Hi,
> I would like to resurrect the following Dave's patch. The last time it
> has been posted was here https://lkml.org/lkml/2010/9/16/250 and there
> didn't seem to be any strong opposition.
> Kosaki was worried about possible excessive logging when somebody drops
> caches too often (but then he claimed he didn't have a strong opinion
> on that) but I would say opposite. If somebody does that then I would
> really like to know that from the log when supporting a system because
> it almost for sure means that there is something fishy going on. It is
> also worth mentioning that only root can write drop caches so this is
> not an flooding attack vector.
> I am bringing that up again because this can be really helpful when
> chasing strange performance issues which (surprise surprise) turn out to
> be related to artificially dropped caches done because the admin thinks
> this would help...
>
> I have just refreshed the original patch on top of the current mm tree
> but I could live with KERN_INFO as well if people think that KERN_NOTICE
> is too hysterical.
> ---
> From 1f4058be9b089bc9d43d71bc63989335d7637d8d Mon Sep 17 00:00:00 2001
> From: Dave Hansen <dave@linux.vnet.ibm.com>
> Date: Fri, 12 Oct 2012 14:30:54 +0200
> Subject: [PATCH] add some drop_caches documentation and info messsge
>
> There is plenty of anecdotal evidence and a load of blog posts
> suggesting that using "drop_caches" periodically keeps your system
> running in "tip top shape".  Perhaps adding some kernel
> documentation will increase the amount of accurate data on its use.
>
> If we are not shrinking caches effectively, then we have real bugs.
> Using drop_caches will simply mask the bugs and make them harder
> to find, but certainly does not fix them, nor is it an appropriate
> "workaround" to limit the size of the caches.
>
> It's a great debugging tool, and is really handy for doing things
> like repeatable benchmark runs.  So, add a bit more documentation
> about it, and add a little KERN_NOTICE.  It should help developers
> who are chasing down reclaim-related bugs.
>
> [mhocko@suse.cz: refreshed to current -mm tree]
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Looks fine.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
