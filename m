Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id D2B596B00C7
	for <linux-mm@kvack.org>; Tue, 19 May 2015 11:13:02 -0400 (EDT)
Received: by labbd9 with SMTP id bd9so29611768lab.2
        for <linux-mm@kvack.org>; Tue, 19 May 2015 08:13:02 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id d5si18986407wie.74.2015.05.19.08.13.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 08:13:01 -0700 (PDT)
Received: by wizk4 with SMTP id k4so121964519wiz.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 08:13:00 -0700 (PDT)
Date: Tue, 19 May 2015 17:15:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150519151541.GJ6203@dhcp22.suse.cz>
References: <20150519104057.GC2462@suse.de>
 <20150519141807.GA9788@cmpxchg.org>
 <20150519144345.GF2462@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150519144345.GF2462@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>

[Let's CC Ben here - the email thread has started here:
http://marc.info/?l=linux-mm&m=143203206402073&w=2 and it seems Debian
is disabling memcg controller already so this might be of your interest]

On Tue 19-05-15 15:43:45, Mel Gorman wrote:
[...]
> After I wrote the patch, I spotted that Debian apparently already
> does something like this and by coincidence they matched the
> parameter name and values. See the memory controller instructions on
> https://wiki.debian.org/LXC#Prepare_the_host . So in this case at least
> upstream would match something that at least one distro in the field
> already uses.

I've read through
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=534964 and it seems
that the primary motivation for the runtime disabling was the _memory_
overhead of the struct page_cgroup
(https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=534964#152). This is
no longer the case since 1306a85aed3e ("mm: embed the memcg pointer
directly into struct page") merged in 3.19.

I can see some point in disabling the memcg due to runtime overhead.
There will always be some, albeit hard to notice. If an user really need
this to happen there is a command line option for that. The question is
who would do CONFIG_MEMCG && !MEMCG_DEFAULT_ENABLED.  Do you expect any
distributions go that way?
Ben, would you welcome such a change upstream or is there a reason to
change the Debian kernel runtime default now that the memory overhead is
mostly gone (for 3.19+ kernels of course)?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
