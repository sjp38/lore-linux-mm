Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 9EAD26B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 14:58:23 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xa12so1575609pbc.22
        for <linux-mm@kvack.org>; Wed, 20 Mar 2013 11:58:22 -0700 (PDT)
Date: Wed, 20 Mar 2013 11:58:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, hugetlb: include hugepages in meminfo
In-Reply-To: <20130320185618.GC970@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1303201157120.17761@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1303191714440.13526@chino.kir.corp.google.com> <20130320095306.GA21856@dhcp22.suse.cz> <alpine.DEB.2.02.1303201145260.17761@chino.kir.corp.google.com> <20130320185618.GC970@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 20 Mar 2013, Michal Hocko wrote:

> > I didn't do this because it isn't already exported in /proc/meminfo and 
> > since we've made an effort to reduce the amount of information emitted by 
> > the oom killer at oom kill time to avoid spamming the kernel log, I only 
> > print the default hstate.
> 
> I do not see how this would make the output too much excessive. If
> you do not want to have too many lines in the output then the hstate
> loop can be pushed inside the node loop and have only per-node number
> of lines same as you are proposing except you would have a complete
> information.
> Besides that we are talking about handful of hstates.
> 

Sigh.  Because nobody is going to be mapping non-default hstates and then 
not know about them at oom time; 1GB hugepages on x86 with pse must be 
reserved at boot and never freed, for example.  I'll add them but it's 
just a waste of time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
