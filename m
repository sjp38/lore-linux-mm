Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64BE5280901
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 09:45:43 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id b140so3882178wme.3
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 06:45:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7si3106392wma.160.2017.03.10.06.45.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 06:45:42 -0800 (PST)
Date: Fri, 10 Mar 2017 15:45:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] Enable parallel page migration
Message-ID: <20170310144539.GK3753@dhcp22.suse.cz>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
 <ef5efef8-a8c5-a4e7-ffc7-44176abec65c@linux.vnet.ibm.com>
 <20170309150904.pnk6ejeug4mktxjv@suse.de>
 <2a2827d0-53d0-175b-8ed4-262629e01984@nvidia.com>
 <20170309221522.hwk4wyaqx2jonru6@suse.de>
 <58C1E948.9020306@cs.rutgers.edu>
 <20170310140715.z6ostiatqx5oiu2i@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170310140715.z6ostiatqx5oiu2i@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, David Nellans <dnellans@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri 10-03-17 14:07:16, Mel Gorman wrote:
> On Thu, Mar 09, 2017 at 05:46:16PM -0600, Zi Yan wrote:
[...]
> > I understand your concern on CPU utilization impact. I think checking
> > CPU utilization and only using idle CPUs could potentially avoid this
> > problem.
> > 
> 
> That will be costly to detect actually. It would require poking into the
> scheduler core and incurring a number of cache misses for a race-prone
> operation that may not succeed. Even if you do it, it'll still be
> brought up that the serialised case should be optimised first.

do not forget that seeing idle cpus is not a sufficient criterion to use
it for parallel migration. There might be other policies you are not
aware of from the MM code to keep them idle (power saving and who knows
what else). Developing a reasonable strategy for spreading the load to
different CPUs is really hard, much harder than you can imaging I
suspect (just look at how hard it was and I long it took to get to a
reasonable scheduler driven frequency scaling/power governors).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
