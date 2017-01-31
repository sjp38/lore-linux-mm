Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 644056B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 11:00:34 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so71189109wjb.5
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 08:00:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 51si21289524wra.235.2017.01.31.08.00.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Jan 2017 08:00:32 -0800 (PST)
Date: Tue, 31 Jan 2017 16:00:29 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] cpuset: Enable changing of top_cpuset's mems_allowed
 nodemask
Message-ID: <20170131160029.ubt6fvw6oh2fgxpd@suse.de>
References: <20170130203003.dm2ydoi3e6cbbwcj@suse.de>
 <20170131142237.27097-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170131142237.27097-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Tue, Jan 31, 2017 at 07:52:37PM +0530, Anshuman Khandual wrote:
> At present, top_cpuset.mems_allowed is same as node_states[N_MEMORY] and it
> cannot be changed at the runtime. Maximum possible node_states[N_MEMORY]
> also gets reflected in top_cpuset.effective_mems interface. It prevents some
> one from removing or restricting memory placement which will be applicable
> system wide on a given memory node through cpuset mechanism which might be
> limiting. This solves the problem by enabling update_nodemask() function to
> accept changes to top_cpuset.mems_allowed as well. Once changed, it also
> updates the value of top_cpuset.effective_mems. Updates all it's task's
> mems_allowed nodemask as well. It calls cpuset_inc() to make sure cpuset
> is accounted for in the buddy allocator through cpusets_enabled() check.
> 

What's the point of allowing the root cpuset to be restricted?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
