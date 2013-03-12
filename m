Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 33ED76B0037
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 12:13:21 -0400 (EDT)
Date: Tue, 12 Mar 2013 17:13:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] device: separate all subsys mutexes (was: Re: [BUG]
 potential deadlock led by cpu_hotplug lock (memcg involved))
Message-ID: <20130312161314.GA5963@dhcp22.suse.cz>
References: <513ECCFE.3070201@huawei.com>
 <20130312101555.GB30758@dhcp22.suse.cz>
 <20130312110750.GC30758@dhcp22.suse.cz>
 <20130312130504.GD30758@dhcp22.suse.cz>
 <1363102105.24558.4.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363102105.24558.4.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Li Zefan <lizefan@huawei.com>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Ingo Molnar <mingo@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue 12-03-13 16:28:25, Peter Zijlstra wrote:
> On Tue, 2013-03-12 at 14:05 +0100, Michal Hocko wrote:
> > @@ -111,17 +111,17 @@ struct bus_type {
> >         struct iommu_ops *iommu_ops;
> >  
> >         struct subsys_private *p;
> > +       struct lock_class_key __key;
> >  };
> 
> Is struct bus_type constrained to static storage or can people go an
> allocate this stuff dynamically?

All of them should be static, at least this is what my cscope says. I
might have missed something of course - I am not very familiar with this
area to be 100% sure.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
