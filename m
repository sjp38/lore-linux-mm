Date: Thu, 4 May 2006 08:13:57 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: RFC: RCU protected page table walking
Message-ID: <20060504131357.GD18857@lnx-holt.americas.sgi.com>
References: <4458CCDC.5060607@bull.net> <200605041131.46254.ak@suse.de> <4459E663.10008@bull.net> <200605041400.34851.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200605041400.34851.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Zoltan.Menyhart@free.fr, "Chen, Kenneth W" <kenneth.w.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 04, 2006 at 02:00:34PM +0200, Andi Kleen wrote:
> On Thursday 04 May 2006 13:32, Zoltan Menyhart wrote:
> > Walking the page tables in physical mode 
> 
> What do you mean with "physical mode"?

ia64 has a software page table walker in ivt.S.  It does its work
using physical addresses.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
