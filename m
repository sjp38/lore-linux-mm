From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/7] [RFC] Sizing zones and holes in an architecture independent manner V2
Date: Thu, 13 Apr 2006 01:53:07 +0200
References: <20060412232036.18862.84118.sendpatchset@skynet>
In-Reply-To: <20060412232036.18862.84118.sendpatchset@skynet>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604130153.08604.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: davej@codemonkey.org.uk, tony.luck@intel.com, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, bob.picco@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 13 April 2006 01:20, Mel Gorman wrote:
> This is V2 of the patchset. They have been boot tested on x86, ppc64
> and x86_64 but I still need to do a double check that zones are the
> same size before and after the patch on all arches. IA64 passed a
> basic compile-test. a driver program that fed in the values generated
> by IA64 to add_active_range(), zone_present_pages_in_node() and
> zone_absent_pages_in_node() seemed to generate expected values.

For x86-64  the new code seems far more complicated than the old one and keeps
the same information in two places now. I have my doubts that is really a 
improvement over the old state.

I think it would be better if you just defined some simple "library functions"
that can be called from the architecture specific code instead of adding
all this new high level code.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
