Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D67916B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 12:20:12 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so3663949pab.22
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 09:20:12 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id l1si430775paw.69.2014.04.04.09.20.11
        for <linux-mm@kvack.org>;
        Fri, 04 Apr 2014 09:20:12 -0700 (PDT)
Message-ID: <533EDB63.8090909@intel.com>
Date: Fri, 04 Apr 2014 09:18:43 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] mm: move FAULT_AROUND_ORDER to arch/
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com> <1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com>
In-Reply-To: <1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org

On 04/03/2014 11:27 PM, Madhavan Srinivasan wrote:
> This patch creates infrastructure to move the FAULT_AROUND_ORDER
> to arch/ using Kconfig. This will enable architecture maintainers
> to decide on suitable FAULT_AROUND_ORDER value based on
> performance data for that architecture. Patch also adds
> FAULT_AROUND_ORDER Kconfig element in arch/X86.

Please don't do it this way.

In mm/Kconfig, put

	config FAULT_AROUND_ORDER
		int
		default 1234 if POWERPC
		default 4

The way you have it now, every single architecture that needs to enable
this has to go put that in their Kconfig.  That's madness.  This way,
you only put it in one place, and folks only have to care if they want
to change the default to be something other than 4.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
