Message-Id: <4t153d$ofhg7@azsmga001.ch.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [RFC] - Kernel text replication on IA64
Date: Thu, 20 Apr 2006 10:48:09 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060420164111.GA18770@agluck-lia64.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Jack Steiner <steiner@sgi.com>
Cc: linux-ia64@vger.kernel.org, lee.schermerhorn@hp.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Luck, Tony wrote on Thursday, April 20, 2006 9:41 AM
> On Thu, Apr 20, 2006 at 08:53:16AM -0500, Jack Steiner wrote:
> > Enabling replication reserves 1 additional DTLB entry for kernel code.
> > This reduces the number of DTLB entries that is available for user code.
> > There is the potential that this could impact some applications.
> > Additional measurements are still needed.
> 
> Ken's recent patch to free up the DTLB that is currently used for per-cpu
> data would mitigate this (though I'm sure he'll be unamused if I blow the
> 1.6% gain he saw on his transaction processing benchmark on this :-)

How much benefit is there to have readonly section replicated?  Do you really
have to use two DTRs - one to map the readonly and one to map rw?

What about just replicate text so we don't need to burn an extra DTR?

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
