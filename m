Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id F11AB6B0031
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 04:29:40 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so3670684pad.31
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 01:29:40 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id br1si505843pbd.324.2014.04.10.01.29.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 01:29:39 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Thu, 10 Apr 2014 13:59:34 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 76F25E004B
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 14:03:45 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3A8Ta1m3736058
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 13:59:36 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3A8TU0N018176
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 13:59:31 +0530
Message-ID: <53465669.80701@linux.vnet.ibm.com>
Date: Thu, 10 Apr 2014 13:59:29 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] mm: move FAULT_AROUND_ORDER to arch/
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com> <1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com> <533EDB63.8090909@intel.com> <5344A312.80802@linux.vnet.ibm.com> <20140409082008.GA10526@twins.programming.kicks-ass.net> <53456BE2.90905@intel.com>
In-Reply-To: <53456BE2.90905@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, mingo@kernel.org

On Wednesday 09 April 2014 09:18 PM, Dave Hansen wrote:
> On 04/09/2014 01:20 AM, Peter Zijlstra wrote:
>> This still misses out on Ben's objection that its impossible to get this
>> right at compile time for many kernels, since they can boot and run on
>> many different subarchs.
> 
> Completely agree.  The Kconfig-time stuff should probably just be a knob
> to turn it off completely, if anything.
> 

ok. Here is my thought. So to address Ben's concern, it would be better
to have this as a variable with a default value (and the platform can
override ride it). And a mm/Kconfig to disable it?
Kindly let me know whether this will work.

Thanks for review comments.
With regards
Maddy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
