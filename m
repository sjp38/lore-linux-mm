Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D36366B30E6
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 14:11:35 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s1-v6so6613061pfm.22
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 11:11:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x63-v6sor2715687pfk.132.2018.08.24.11.11.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 11:11:34 -0700 (PDT)
Date: Sat, 25 Aug 2018 02:11:27 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 3/3] mm/sparse: use __highest_present_section_nr as the
 boundary for pfn check
Message-ID: <20180824181127.GA11055@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-4-richard.weiyang@gmail.com>
 <4bb956bd-a061-7122-2c2d-7c910a176681@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4bb956bd-a061-7122-2c2d-7c910a176681@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On Thu, Aug 23, 2018 at 05:15:39PM -0700, Dave Hansen wrote:
>On 08/23/2018 06:07 AM, Wei Yang wrote:
>> And it is known, __highest_present_section_nr is a more strict boundary
>> than NR_MEM_SECTIONS.
>
>What is the benefit of this patch?
>

The original idea is simple: with a more strict boundary, it will has less
computation.

>You're adding a more "strict" boundary, but you're also adding a
>potential cacheline miss and removing optimizations that the compiler
>can make with a constant vs. a variable.  Providing absolute bounds
>limits that the compiler knows about can actually be pretty handy for it
>to optimize things

You are right.

I haven't thought about the compiler optimization case.

>
>Do you have *any* analysis to show that this has a benefit?  What does
>it do to text size, for instance?

I don't have more analysis about this. Originally, I thought a strict boundary
will have a benefit. But as you mentioned, it loose the compiler optimization.

BTW, I did some tests and found during a normal boot, all the section number
are within NR_MEM_SECTIONS. I am wondering in which case, this check will be
valid and return 0?

-- 
Wei Yang
Help you, Help me
