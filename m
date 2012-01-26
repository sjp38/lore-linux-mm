Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id ED1046B0087
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 04:01:18 -0500 (EST)
Date: Thu, 26 Jan 2012 10:01:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix compile warning on non-numa systems
Message-ID: <20120126090115.GB13421@tiehlicka.suse.cz>
References: <4F13BE05.70505@cn.fujitsu.com>
 <20120116084715.GA1639@tiehlicka.suse.cz>
 <20120126005521.07ac0faf.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120126005521.07ac0faf.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu 26-01-12 00:55:21, Andrew Morton wrote:
> On Mon, 16 Jan 2012 09:47:15 +0100 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Mon 16-01-12 14:04:53, Li Zefan wrote:
> > > Fix this warning:
> > > 
> > >   CC      mm/memcontrol.o
> > > mm/memcontrol.c: In function 'memcg_check_events':
> > > mm/memcontrol.c:779:22: warning: unused variable 'do_numainfo'
> > 
> > This has been already posted by Kirill and I didn't like the solution
> > (https://lkml.org/lkml/2011/12/27/86). He then reposted with a different
> > version (https://lkml.org/lkml/2012/1/6/281).
> > The later one looks better but I still think this is not worth
> > complicate the code just to get rid of this warning.
> 
> This?

Haven't seen this one but it looks sane.
Acked-by: Michal Hocko <mhocko@suse.cz>

> 
> --- a/mm/memcontrol.c~a
> +++ a/mm/memcontrol.c
> @@ -776,7 +776,8 @@ static void memcg_check_events(struct me
>  	/* threshold event is triggered in finer grain than soft limit */
>  	if (unlikely(mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_THRESH))) {
> -		bool do_softlimit, do_numainfo;
> +		bool do_softlimit;
> +		bool do_numainfo __maybe_unused;
>  
>  		do_softlimit = mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_SOFTLIMIT);
> _
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
