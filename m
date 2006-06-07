From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/5] Sizing zones and holes in an architecture independent manner V7
Date: Wed, 7 Jun 2006 11:45:04 +0200
References: <20060606134710.21419.48239.sendpatchset@skynet.skynet.ie> <20060606164311.27d4af98.akpm@osdl.org> <Pine.LNX.4.64.0606071030100.20653@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0606071030100.20653@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606071145.04938.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@osdl.org>, davej@codemonkey.org.uk, tony.luck@intel.com, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Spanned pages and holes will be different on 
> x86_64 because I don't account the kernel image and memmap as holes. 

That's a significant inaccuracy and may give worse VM results.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
