Date: Thu, 28 Oct 2004 08:49:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA node swapping V3
In-Reply-To: <1275120000.1098978003@[10.10.2.4]>
Message-ID: <Pine.LNX.4.58.0410280845520.25586@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0410280820500.25586@schroedinger.engr.sgi.com>
 <1275120000.1098978003@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Oct 2004, Martin J. Bligh wrote:

> I thought even the SGI people were saying this wouldn't actually help you,
> due to some workload issues?

Our tests show that this does indeed address the issue. There may still be
some off node allocation while kswapd is starting up which causes some
objections but avoiding these would mean significant modifications to
__alloc_pages. This is a fix until a better solution can be found which I
would estimate to be 3-6 months down the road given the difficulties
getting vm changes into the kernel.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
