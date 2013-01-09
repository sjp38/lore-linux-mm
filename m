Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 3AD9D6B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 15:39:53 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fb1so1263583pad.39
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 12:39:52 -0800 (PST)
Date: Wed, 9 Jan 2013 12:39:45 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130109203945.GB20454@htj.dyndns.org>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <20130109203731.GA20454@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130109203731.GA20454@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Wed, Jan 09, 2013 at 12:37:31PM -0800, Tejun Heo wrote:
> Hello,
> 
> Can you please cc me too when posting further patches?  I kinda missed
> the whole discussion upto this point.
> 
> On Fri, Jan 04, 2013 at 12:29:11AM -0800, Anton Vorontsov wrote:
> > This commit implements David Rientjes' idea of mempressure cgroup.
> > 
> > The main characteristics are the same to what I've tried to add to vmevent
> > API; internally, it uses Mel Gorman's idea of scanned/reclaimed ratio for
> > pressure index calculation. But we don't expose the index to the userland.
> > Instead, there are three levels of the pressure:
> > 
> >  o low (just reclaiming, e.g. caches are draining);
> >  o medium (allocation cost becomes high, e.g. swapping);
> >  o oom (about to oom very soon).
> > 
> > The rationale behind exposing levels and not the raw pressure index
> > described here: http://lkml.org/lkml/2012/11/16/675
> > 
> > For a task it is possible to be in both cpusets, memcg and mempressure
> > cgroups, so by rearranging the tasks it is possible to watch a specific
> > pressure (i.e. caused by cpuset and/or memcg).
> 
> So, cgroup is headed towards single hierarchy.  Dunno how much it
> would affect mempressure but it probably isn't wise to design with
> focus on multiple hierarchies.

Also, how are you implementing hierarchical behavior?  All controllers
should support hierarchy.  Can you please explain how the interface
would work in detail?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
