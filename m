From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Only process_die notifier in ia64_do_page_fault if KPROBES is configured.
Date: Wed, 31 Aug 2005 01:38:08 +0200
References: <B8E391BBE9FE384DAA4C5C003888BE6F0443A9A1@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0443A9A1@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508310138.09841.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Rusty Lynch <rusty@linux.intel.com>, "Lynch, Rusty" <rusty.lynch@intel.com>, linux-mm@kvack.org, prasanna@in.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 31 August 2005 01:05, Luck, Tony wrote:
> >Please do not generate any code if the feature cannot ever be
> >used (CONFIG_KPROBES off). With this patch we still have lots of
> >unnecessary code being executed on each page fault.
>
> I can (eventually) wrap this call inside the #ifdef CONFIG_KPROBES.

At least the original die notifiers were designed as a generic debugger
interface, not a kprobes specific thing. So I don't think it's a good idea.
Given most debuggers don't need the early page fault hook and it's
mostly needed for a special case in kprobes, but it doesn't seem nice to only 
offer a subset of the hooks with specific config options.

Also with the inline the test should be essentially a single test of 
a global variable and jump. Hardly a big performance issue, no? 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
