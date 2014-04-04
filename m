Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7156B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 13:49:24 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so3634887pdi.2
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 10:49:23 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id pc9si4880564pac.148.2014.04.04.10.49.22
        for <linux-mm@kvack.org>;
        Fri, 04 Apr 2014 10:49:22 -0700 (PDT)
Date: Fri, 04 Apr 2014 13:50:56 -0400 (EDT)
Message-Id: <20140404.135056.2103520199689146670.davem@davemloft.net>
Subject: Re: [PATCH V2 1/2] mm: move FAULT_AROUND_ORDER to arch/
From: David Miller <davem@davemloft.net>
In-Reply-To: <533EDB63.8090909@intel.com>
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com>
	<1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com>
	<533EDB63.8090909@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: maddy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org

From: Dave Hansen <dave.hansen@intel.com>
Date: Fri, 04 Apr 2014 09:18:43 -0700

> On 04/03/2014 11:27 PM, Madhavan Srinivasan wrote:
>> This patch creates infrastructure to move the FAULT_AROUND_ORDER
>> to arch/ using Kconfig. This will enable architecture maintainers
>> to decide on suitable FAULT_AROUND_ORDER value based on
>> performance data for that architecture. Patch also adds
>> FAULT_AROUND_ORDER Kconfig element in arch/X86.
> 
> Please don't do it this way.
> 
> In mm/Kconfig, put
> 
> 	config FAULT_AROUND_ORDER
> 		int
> 		default 1234 if POWERPC
> 		default 4
> 
> The way you have it now, every single architecture that needs to enable
> this has to go put that in their Kconfig.  That's madness.  This way,
> you only put it in one place, and folks only have to care if they want
> to change the default to be something other than 4.

It looks more like it's necessary only to change the default, not
to enable it.  Unless I read his patch wrong...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
