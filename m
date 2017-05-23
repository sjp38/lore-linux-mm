Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 978DD6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 02:39:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g143so27854549wme.13
        for <linux-mm@kvack.org>; Mon, 22 May 2017 23:39:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si16705490wrc.284.2017.05.22.23.39.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 23:39:13 -0700 (PDT)
Date: Tue, 23 May 2017 08:39:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] refine and rename slub sysfs
Message-ID: <20170523063911.GC12813@dhcp22.suse.cz>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
 <20170518090636.GA25471@dhcp22.suse.cz>
 <20170523032705.GA4275@WeideMBP.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170523032705.GA4275@WeideMBP.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 23-05-17 11:27:05, Wei Yang wrote:
> On Thu, May 18, 2017 at 11:06:37AM +0200, Michal Hocko wrote:
> >On Wed 17-05-17 22:11:40, Wei Yang wrote:
> >> This patch serial could be divided into two parts.
> >> 
> >> First three patches refine and adds slab sysfs.
> >> Second three patches rename slab sysfs.
> >> 
> >> 1. Refine slab sysfs
> >> 
> >> There are four level slabs:
> >> 
> >>     CPU
> >>     CPU_PARTIAL
> >>     PARTIAL
> >>     FULL
> >> 
> >> And in sysfs, it use show_slab_objects() and cpu_partial_slabs_show() to
> >> reflect the statistics.
> >> 
> >> In patch 2, it splits some function in show_slab_objects() which makes sure
> >> only cpu_partial_slabs_show() covers statistics for CPU_PARTIAL slabs.
> >> 
> >> After doing so, it would be more clear that show_slab_objects() has totally 9
> >> statistic combinations for three level of slabs. Each slab has three cases
> >> statistic.
> >> 
> >>     slabs
> >>     objects
> >>     total_objects
> >> 
> >> And when we look at current implementation, some of them are missing. So patch
> >> 2 & 3 add them up.
> >> 
> >> 2. Rename sysfs
> >> 
> >> The slab statistics in sysfs are
> >> 
> >>     slabs
> >>     objects
> >>     total_objects
> >>     cpu_slabs
> >>     partial
> >>     partial_objects
> >>     cpu_partial_slabs
> >> 
> >> which is a little bit hard for users to understand. The second three patches
> >> rename sysfs file in this pattern.
> >> 
> >>     xxx_slabs[[_total]_objects]
> >> 
> >> Finally it looks Like
> >> 
> >>     slabs
> >>     slabs_objects
> >>     slabs_total_objects
> >>     cpu_slabs
> >>     cpu_slabs_objects
> >>     cpu_slabs_total_objects
> >>     partial_slabs
> >>     partial_slabs_objects
> >>     partial_slabs_total_objects
> >>     cpu_partial_slabs
> >
> >_Why_ do we need all this?
> 
> To have a clear statistics for each slab level.

Is this worth risking breakage of the userspace which consume this data
now? Do you have any user space code which will greatly benefit from the
new data and which couldn't do the same with the current format/output?

If yes this all should be in the changelog.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
