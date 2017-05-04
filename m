Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2791C6B0038
	for <linux-mm@kvack.org>; Thu,  4 May 2017 13:33:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b17so14653154pfd.1
        for <linux-mm@kvack.org>; Thu, 04 May 2017 10:33:36 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o1si2703953pge.355.2017.05.04.10.33.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 10:33:35 -0700 (PDT)
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <20170502143608.GM14593@dhcp22.suse.cz> <1493875615.7934.1.camel@gmail.com>
 <20170504125250.GH31540@dhcp22.suse.cz>
 <1493912961.25766.379.camel@kernel.crashing.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ac379467-0f9b-bbb2-955e-e677d94200f1@intel.com>
Date: Thu, 4 May 2017 10:33:34 -0700
MIME-Version: 1.0
In-Reply-To: <1493912961.25766.379.camel@kernel.crashing.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michal Hocko <mhocko@suse.com>, Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On 05/04/2017 08:49 AM, Benjamin Herrenschmidt wrote:
> On Thu, 2017-05-04 at 14:52 +0200, Michal Hocko wrote:
>> But the direct reclaim would be effective only _after_ all other nodes
>> are full.
>>
>> I thought that kswapd reclaim is a problem because the HW doesn't
>> support aging properly but as the direct reclaim works then what is the
>> actual problem?
> 
> Ageing isn't isn't completely broken. The ATS MMU supports
> dirty/accessed just fine.
> 
> However the TLB invalidations are quite expensive with a GPU so too
> much harvesting is detrimental, and the GPU tends to check pages out
> using a special "read with intend to write" mode, which means it almost
> always set the dirty bit if the page is writable to begin with.

Why do you have to invalidate the TLB?  Does the GPU have a TLB so large
that it can keep thing in the TLB for super-long periods of time?

We don't flush the TLB on clearing Accessed on x86 normally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
