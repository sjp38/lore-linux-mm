Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 929FD6B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 14:46:15 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id q10so721000pdj.40
        for <linux-mm@kvack.org>; Wed, 20 Mar 2013 11:46:14 -0700 (PDT)
Date: Wed, 20 Mar 2013 11:46:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, hugetlb: include hugepages in meminfo
In-Reply-To: <20130320095306.GA21856@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1303201145260.17761@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1303191714440.13526@chino.kir.corp.google.com> <20130320095306.GA21856@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 20 Mar 2013, Michal Hocko wrote:

> On Tue 19-03-13 17:18:12, David Rientjes wrote:
> > Particularly in oom conditions, it's troublesome that hugetlb memory is 
> > not displayed.  All other meminfo that is emitted will not add up to what 
> > is expected, and there is no artifact left in the kernel log to show that 
> > a potentially significant amount of memory is actually allocated as 
> > hugepages which are not available to be reclaimed.
> 
> Yes, I like the idea. It's bitten me already in the past.
> 
> The only objection I have is that you print only default_hstate. You
> just need to wrap your for_each_node_state by for_each_hstate to do
> that.  With that applied, feel free to add my
> Acked-by: Michal Hocko <mhocko@suse.cz>
> 

I didn't do this because it isn't already exported in /proc/meminfo and 
since we've made an effort to reduce the amount of information emitted by 
the oom killer at oom kill time to avoid spamming the kernel log, I only 
print the default hstate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
