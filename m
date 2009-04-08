Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A5B245F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 03:52:53 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n387rbH1023318
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 13:23:37 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n387nkYs4284506
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 13:19:46 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n387raWx031665
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 17:53:37 +1000
Date: Wed, 8 Apr 2009 13:22:40 +0530
From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-ID: <20090408075240.GA16028@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
References: <20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com> <20090408052904.GY7082@balbir.in.ibm.com> <20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com> <20090408070401.GC7082@balbir.in.ibm.com> <20090408160733.4813cb8d.kamezawa.hiroyu@jp.fujitsu.com> <20090408071115.GD7082@balbir.in.ibm.com> <20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com> <344eb09a0904080031y4406c001n584725b87024755@mail.gmail.com> <20090408163440.4442dc3c.kamezawa.hiroyu@jp.fujitsu.com> <344eb09a0904080045s94c792dmc2250aaf39c09222@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <344eb09a0904080045s94c792dmc2250aaf39c09222@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bharata B Rao <bharata.rao@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 08, 2009 at 01:15:01PM +0530, Bharata B Rao wrote:
> On Wed, Apr 8, 2009 at 1:04 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 8 Apr 2009 13:01:15 +0530
> > Bharata B Rao <bharata.rao@gmail.com> wrote:
> >
> >> On Wed, Apr 8, 2009 at 12:48 PM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> >
> >> > On Wed, 8 Apr 2009 12:41:15 +0530
> >> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> > > 3. Using the above, we can then try to (using an algorithm you
> >> > > proposed), try to do some work for figuring out the shared percentage.
> >> > >
> >> > This is the point. At last. Why "# of shared pages" is important ?
> >> >
> >> > I wonder it's better to add new stat file as memory.cacheinfo which helps
> >> > following kind of commands.
> >> >
> >> >  #cacheinfo /cgroups/memory/group01/
> >> >       /usr/lib/libc.so.1     30pages
> >> >       /var/log/messages      1 pages
> >> >       /tmp/xxxxxx            20 pages
> >>
> >> Can I suggest that we don't add new files for additional stats and try
> >> as far as possible to include them in <controller>.stat file. Please
> >> note that we have APIs in libcgroup library which can return
> >> statistics from controllers associated with a cgroup and these APIs
> >> assume that stats are part of <controller>.stat file.
> >>
> > Hmm ? Is there generic assumption as all cgroup has "stat" file ?
> 
> No. But I would think if any controller has any stats to export, it
> would do so via <controller>.stat file.
> 
> > And libcgroup cause bug if the new entry is added to stat file ?
> 
> No. It can cope with new entries being added to stat file as long as
> they appear as (name, value) pairs.
> 

And if it does not, we should fix it to cope up with it. But I agree
with bharata, we should avoid adding new files, and try to use the stat
file.

thanks,
-- 
regards,
Dhaval

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
