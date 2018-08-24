Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 375436B2CD2
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 20:15:41 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n17-v6so4498989pff.17
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 17:15:41 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b87-v6si1735852pfm.5.2018.08.23.17.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 17:15:40 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm/sparse: use __highest_present_section_nr as the
 boundary for pfn check
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-4-richard.weiyang@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4bb956bd-a061-7122-2c2d-7c910a176681@intel.com>
Date: Thu, 23 Aug 2018 17:15:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180823130732.9489-4-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On 08/23/2018 06:07 AM, Wei Yang wrote:
> And it is known, __highest_present_section_nr is a more strict boundary
> than NR_MEM_SECTIONS.

What is the benefit of this patch?

You're adding a more "strict" boundary, but you're also adding a
potential cacheline miss and removing optimizations that the compiler
can make with a constant vs. a variable.  Providing absolute bounds
limits that the compiler knows about can actually be pretty handy for it
to optimize things

Do you have *any* analysis to show that this has a benefit?  What does
it do to text size, for instance?
