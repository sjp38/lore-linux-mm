Date: Mon, 22 Nov 2004 14:51:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page fault scalability patch V11 [0/7]: overview
In-Reply-To: <20041122224333.GI2714@holomorphy.com>
Message-ID: <Pine.LNX.4.58.0411221450500.22895@schroedinger.engr.sgi.com>
References: <20041120062341.GM2714@holomorphy.com> <419EE911.20205@yahoo.com.au>
 <20041119225701.0279f846.akpm@osdl.org> <419EEE7F.3070509@yahoo.com.au>
 <1834180000.1100969975@[10.10.2.4]> <Pine.LNX.4.58.0411200911540.20993@ppc970.osdl.org>
 <20041120190818.GX2714@holomorphy.com> <Pine.LNX.4.58.0411201112200.20993@ppc970.osdl.org>
 <20041120193325.GZ2714@holomorphy.com> <Pine.LNX.4.58.0411220932270.22144@schroedinger.engr.sgi.com>
 <20041122224333.GI2714@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, benh@kernel.crashing.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2004, William Lee Irwin III wrote:

> The specific patches you compared matter a great deal as there are
> implementation blunders (e.g. poor placement of counters relative to
> ->mmap_sem) that can ruin the results. URL's to the specific patches
> would rule out that source of error.

I mentioned V4 of this patch which was posted to lkml. A simple search
should get you there.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
