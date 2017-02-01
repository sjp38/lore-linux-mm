Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0305A6B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 03:53:29 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id q124so3870805wmg.2
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 00:53:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u73si24000934wrc.271.2017.02.01.00.53.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Feb 2017 00:53:27 -0800 (PST)
Date: Wed, 1 Feb 2017 09:53:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] cpuset: Enable changing of top_cpuset's mems_allowed
 nodemask
Message-ID: <20170201085326.GE5977@dhcp22.suse.cz>
References: <20170130203003.dm2ydoi3e6cbbwcj@suse.de>
 <20170131142237.27097-1-khandual@linux.vnet.ibm.com>
 <20170131160029.ubt6fvw6oh2fgxpd@suse.de>
 <c6864b3c-1b7f-ded9-eea4-538262631813@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c6864b3c-1b7f-ded9-eea4-538262631813@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Wed 01-02-17 13:01:24, Anshuman Khandual wrote:
[...]
> More importantly it also extends the cpuset memory restriction feature
> to the logical completion without adding any regressions for the
> existing use cases. Then why not do this ? Does it add any overhead ?

Maybe it doesn't add any overhead but it just breaks the cgroups
expectation that the root cgroup covers the full resource set. No cgroup
controller allows to set limits on the root cgroup. So all this looks
like an abuse of the interface.

I haven't read the full series yet but this particular change looks like
a nogo to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
