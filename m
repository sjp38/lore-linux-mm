Date: Thu, 12 May 2005 16:49:02 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: NUMA aware slab allocator V2
Message-ID: <20050512214902.GA18835@lnx-holt.americas.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

Christoph,

Can you let me know when this is in so I can modify the ia64 pgalloc.h
to not use the quicklists any longer?

Thanks,
Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
