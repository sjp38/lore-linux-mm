Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 69D506B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 10:51:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q125so6409033pgq.8
        for <linux-mm@kvack.org>; Fri, 05 May 2017 07:51:24 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m5si2150377pgj.102.2017.05.05.07.51.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 07:51:23 -0700 (PDT)
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <20170502143608.GM14593@dhcp22.suse.cz> <1493875615.7934.1.camel@gmail.com>
 <20170504125250.GH31540@dhcp22.suse.cz>
 <1493912961.25766.379.camel@kernel.crashing.org>
 <ac379467-0f9b-bbb2-955e-e677d94200f1@intel.com>
 <1493954234.4227.1.camel@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a7d3f513-4e20-de82-5b8a-14cd1efea439@intel.com>
Date: Fri, 5 May 2017 07:51:21 -0700
MIME-Version: 1.0
In-Reply-To: <1493954234.4227.1.camel@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On 05/04/2017 08:17 PM, Balbir Singh wrote:
>>> However the TLB invalidations are quite expensive with a GPU so too
>>> much harvesting is detrimental, and the GPU tends to check pages out
>>> using a special "read with intend to write" mode, which means it almost
>>> always set the dirty bit if the page is writable to begin with.
>> Why do you have to invalidate the TLB?  Does the GPU have a TLB so large
>> that it can keep thing in the TLB for super-long periods of time?
>>
>> We don't flush the TLB on clearing Accessed on x86 normally.
> Isn't that mostly because x86 relies on non-global pages to be flushed
> on context switch?

Well, that's not the case with Process Context Identifiers.  Somebody
will enable those some day.  It also isn't true for a long-lived process
camping on a CPU core.

I don't know about "mostly", but it's certainly a combination of stuff
having to be reloaded in the TLB and flushed at context switch today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
