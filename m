Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 4D16E6B005A
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 11:42:12 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bh2so10768251pad.19
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 08:42:11 -0800 (PST)
Date: Mon, 7 Jan 2013 08:42:06 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 10/13] cpuset: make CPU / memory hotplug propagation
 asynchronous
Message-ID: <20130107164206.GG3926@htj.dyndns.org>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
 <1357248967-24959-11-git-send-email-tj@kernel.org>
 <50E935D5.4040402@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50E935D5.4040402@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 06, 2013 at 04:29:09PM +0800, Li Zefan wrote:
> > +static void schedule_cpuset_propagate_hotplug(struct cpuset *cs)
> > +{
> > +	/*
> > +	 * Pin @cs.  The refcnt will be released when the work item
> > +	 * finishes executing.
> > +	 */
> > +	if (!css_tryget(&cs->css))
> > +		return;
> > +
> > +	/*
> > +	 * Queue @cs->empty_cpuset_work.  If already pending, lose the css
> 
> cs->hotplug_work

Thanks.  Patch updated.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
