Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH] Only process_die notifier in ia64_do_page_fault if KPROBES is configured.
Date: Tue, 30 Aug 2005 16:05:04 -0700
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F0443A9A1@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>, Rusty Lynch <rusty@linux.intel.com>
Cc: Andi Kleen <ak@suse.de>, "Lynch, Rusty" <rusty.lynch@intel.com>, linux-mm@kvack.org, prasanna@in.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>
List-ID: <linux-mm.kvack.org>

>Please do not generate any code if the feature cannot ever be 
>used (CONFIG_KPROBES off). With this patch we still have lots of 
>unnecessary code being executed on each page fault.

I can (eventually) wrap this call inside the #ifdef CONFIG_KPROBES.

But I'd like to keep following leads on making the overhead as
low as possible for those people that do have KPROBES configured
(which may be most people if OS distributors ship kernels with
this enabled).

-Tony
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
