Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id AA8C16B0092
	for <linux-mm@kvack.org>; Wed, 22 May 2013 06:32:37 -0400 (EDT)
Date: Wed, 22 May 2013 12:32:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: don't initialize kmem-cache destroying work for
 root caches
Message-ID: <20130522103233.GB19989@dhcp22.suse.cz>
References: <1368535118-27369-1-git-send-email-avagin@openvz.org>
 <20130514160859.GC5055@dhcp22.suse.cz>
 <20130522074055.GA16207@paralelels.com>
 <519C78C0.3050204@huawei.com>
 <20130522075638.GB16934@paralelels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130522075638.GB16934@paralelels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Vagin <avagin@parallels.com>
Cc: Li Zefan <lizefan@huawei.com>, Andrey Vagin <avagin@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed 22-05-13 11:56:38, Andrew Vagin wrote:
> On Wed, May 22, 2013 at 03:50:24PM +0800, Li Zefan wrote:
> > On 2013/5/22 15:40, Andrew Vagin wrote:
> > > On Tue, May 14, 2013 at 06:08:59PM +0200, Michal Hocko wrote:
> > >>
> > >> Forgot to add
> > >> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> > >> +
> > >> Cc: stable # 3.9
> > >>
> > >> Thanks
> > > 
> > > Who usually picks up such patches?
> > 
> > The famous AKPM.
> >
> 
> Thanks.
> 
> get_maintainer.pl doesn't show Andrew in the list of recipients.

Yes, but most of the mm patches fly via Andrew.

> $ perl scripts/get_maintainer.pl 0001-memcg-don-t-initialize-kmem-cache-destroying-work-fo.patch
> Johannes Weiner <hannes@cmpxchg.org> (maintainer:MEMORY RESOURCE C...)
> Michal Hocko <mhocko@suse.cz> (maintainer:MEMORY RESOURCE C...)
> Balbir Singh <bsingharora@gmail.com> (maintainer:MEMORY RESOURCE C...)
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> (maintainer:MEMORY RESOURCE C...)
> cgroups@vger.kernel.org (open list:MEMORY RESOURCE C...)
> linux-mm@kvack.org (open list:MEMORY RESOURCE C...)
> linux-kernel@vger.kernel.org (open list) 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
