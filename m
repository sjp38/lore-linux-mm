Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id DF1A26B0005
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 15:21:48 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id e51so1373120eek.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2013 12:21:47 -0700 (PDT)
Date: Wed, 20 Mar 2013 20:21:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, hugetlb: include hugepages in meminfo
Message-ID: <20130320192144.GD970@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1303191714440.13526@chino.kir.corp.google.com>
 <20130320095306.GA21856@dhcp22.suse.cz>
 <alpine.DEB.2.02.1303201145260.17761@chino.kir.corp.google.com>
 <20130320185618.GC970@dhcp22.suse.cz>
 <alpine.DEB.2.02.1303201157120.17761@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1303201157120.17761@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 20-03-13 11:58:20, David Rientjes wrote:
> On Wed, 20 Mar 2013, Michal Hocko wrote:
> 
> > > I didn't do this because it isn't already exported in /proc/meminfo and 
> > > since we've made an effort to reduce the amount of information emitted by 
> > > the oom killer at oom kill time to avoid spamming the kernel log, I only 
> > > print the default hstate.
> > 
> > I do not see how this would make the output too much excessive. If
> > you do not want to have too many lines in the output then the hstate
> > loop can be pushed inside the node loop and have only per-node number
> > of lines same as you are proposing except you would have a complete
> > information.
> > Besides that we are talking about handful of hstates.
> > 
> 
> Sigh.  Because nobody is going to be mapping non-default hstates and then 
> not know about them at oom time;

If you are under control of the machine then you are right. But I was
already handling issues where getting any piece of information was
challenging and having this kind of information in the log would save me
a lot of time.

> 1GB hugepages on x86 with pse must be reserved at boot and never
> freed, for example.  I'll add them but it's just a waste of time.

If you feel it is the waste of _your_ time then I am OK to create a folow
up patch. I really do not see any reason to limit this output,
especially when it doesn't cost us much.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
