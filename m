Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6B156B0038
	for <linux-mm@kvack.org>; Thu,  4 May 2017 23:17:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m13so2897430pgd.12
        for <linux-mm@kvack.org>; Thu, 04 May 2017 20:17:23 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id b1si3744874pld.245.2017.05.04.20.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 20:17:22 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id b23so4394566pfc.0
        for <linux-mm@kvack.org>; Thu, 04 May 2017 20:17:22 -0700 (PDT)
Message-ID: <1493954234.4227.1.camel@gmail.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 05 May 2017 13:17:14 +1000
In-Reply-To: <ac379467-0f9b-bbb2-955e-e677d94200f1@intel.com>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <20170502143608.GM14593@dhcp22.suse.cz> <1493875615.7934.1.camel@gmail.com>
	 <20170504125250.GH31540@dhcp22.suse.cz>
	 <1493912961.25766.379.camel@kernel.crashing.org>
	 <ac379467-0f9b-bbb2-955e-e677d94200f1@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Thu, 2017-05-04 at 10:33 -0700, Dave Hansen wrote:
> On 05/04/2017 08:49 AM, Benjamin Herrenschmidt wrote:
> > On Thu, 2017-05-04 at 14:52 +0200, Michal Hocko wrote:
> > > But the direct reclaim would be effective only _after_ all other nodes
> > > are full.
> > > 
> > > I thought that kswapd reclaim is a problem because the HW doesn't
> > > support aging properly but as the direct reclaim works then what is the
> > > actual problem?
> > 
> > Ageing isn't isn't completely broken. The ATS MMU supports
> > dirty/accessed just fine.
> > 
> > However the TLB invalidations are quite expensive with a GPU so too
> > much harvesting is detrimental, and the GPU tends to check pages out
> > using a special "read with intend to write" mode, which means it almost
> > always set the dirty bit if the page is writable to begin with.
> 
> Why do you have to invalidate the TLB?  Does the GPU have a TLB so large
> that it can keep thing in the TLB for super-long periods of time?
> 
> We don't flush the TLB on clearing Accessed on x86 normally.

Isn't that mostly because x86 relies on non-global pages to be flushed
on context switch?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
