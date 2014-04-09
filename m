Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7F85C6B0036
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 11:51:57 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so2608334pdi.16
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 08:51:57 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 7si675673pbe.57.2014.04.09.08.51.56
        for <linux-mm@kvack.org>;
        Wed, 09 Apr 2014 08:51:56 -0700 (PDT)
Message-ID: <53456BE2.90905@intel.com>
Date: Wed, 09 Apr 2014 08:48:50 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] mm: move FAULT_AROUND_ORDER to arch/
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com> <1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com> <533EDB63.8090909@intel.com> <5344A312.80802@linux.vnet.ibm.com> <20140409082008.GA10526@twins.programming.kicks-ass.net>
In-Reply-To: <20140409082008.GA10526@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, mingo@kernel.org

On 04/09/2014 01:20 AM, Peter Zijlstra wrote:
> This still misses out on Ben's objection that its impossible to get this
> right at compile time for many kernels, since they can boot and run on
> many different subarchs.

Completely agree.  The Kconfig-time stuff should probably just be a knob
to turn it off completely, if anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
