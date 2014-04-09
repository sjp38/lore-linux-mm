Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7E46B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 04:20:21 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id rl12so2107490iec.22
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 01:20:21 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id ce9si337722icc.139.2014.04.09.01.20.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Apr 2014 01:20:20 -0700 (PDT)
Date: Wed, 9 Apr 2014 10:20:08 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V2 1/2] mm: move FAULT_AROUND_ORDER to arch/
Message-ID: <20140409082008.GA10526@twins.programming.kicks-ass.net>
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com>
 <1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com>
 <533EDB63.8090909@intel.com>
 <5344A312.80802@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5344A312.80802@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, mingo@kernel.org

On Wed, Apr 09, 2014 at 07:02:02AM +0530, Madhavan Srinivasan wrote:
> On Friday 04 April 2014 09:48 PM, Dave Hansen wrote:
> > On 04/03/2014 11:27 PM, Madhavan Srinivasan wrote:
> >> This patch creates infrastructure to move the FAULT_AROUND_ORDER
> >> to arch/ using Kconfig. This will enable architecture maintainers
> >> to decide on suitable FAULT_AROUND_ORDER value based on
> >> performance data for that architecture. Patch also adds
> >> FAULT_AROUND_ORDER Kconfig element in arch/X86.
> > 
> > Please don't do it this way.
> > 
> > In mm/Kconfig, put
> > 
> > 	config FAULT_AROUND_ORDER
> > 		int
> > 		default 1234 if POWERPC
> > 		default 4
> > 
> > The way you have it now, every single architecture that needs to enable
> > this has to go put that in their Kconfig.  That's madness.  This way,
> 
> I though about it and decided not to do this way because, in future,
> sub platforms of the architecture may decide to change the values. Also,
> adding an if line for each architecture with different sub platforms
> oring to it will look messy.

This still misses out on Ben's objection that its impossible to get this
right at compile time for many kernels, since they can boot and run on
many different subarchs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
