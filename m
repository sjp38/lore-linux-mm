Subject: Re: [PATCH][RFC] memory.min_usage again
In-Reply-To: Your message of "Fri, 12 Sep 2008 18:46:30 +0900"
	<20080912184630.35773102.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080912184630.35773102.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080929004332.13B0083F2@siro.lan>
Date: Mon, 29 Sep 2008 09:43:32 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, containers@lists.osdl.org, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

hi,

> On Wed, 10 Sep 2008 08:32:15 -0700
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > YAMAMOTO Takashi wrote:
> > > hi,
> > > 
> > >> hi,
> > >>
> > >> here's a patch to implement memory.min_usage,
> > >> which controls the minimum memory usage for a cgroup.
> > >>
> > >> it works similarly to mlock;
> > >> global memory reclamation doesn't reclaim memory from
> > >> cgroups whose memory usage is below the value.
> > >> setting it too high is a dangerous operation.
> > >>
> > 
> > Looking through the code I am a little worried, what if every cgroup is below
> > minimum value and the system is under memory pressure, do we OOM, while we could
> > have easily reclaimed?

i'm not sure what you are worring about.  can you explain a little more?
under the configuration, OOM is an expected behaviour.

> > 
> > I would prefer to see some heuristics around such a feature, mostly around the
> > priority that do_try_to_free_pages() to determine how desperate we are for
> > reclaiming memory.
> > 
> Taking "priority" of memory reclaim path into account is good.
> 
> ==
> static unsigned long shrink_inactive_list(unsigned long max_scan,
>                         struct zone *zone, struct scan_control *sc,
>                         int priority, int file)
> ==
> How about ignore min_usage if "priority < DEF_PRIORITY - 2" ?

are you suggesting ignoring mlock etc as well in that case?

YAMAMOTO Takashi

> 
> 
> Thanks,
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
