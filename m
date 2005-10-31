Date: Mon, 31 Oct 2005 11:24:09 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051031112409.153e7048.akpm@osdl.org>
In-Reply-To: <27700000.1130769270@[10.10.2.4]>
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie>
	<20051031055725.GA3820@w-mikek2.ibm.com>
	<4365BBC4.2090906@yahoo.com.au>
	<20051030235440.6938a0e9.akpm@osdl.org>
	<27700000.1130769270@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: nickpiggin@yahoo.com.au, kravetz@us.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@mbligh.org> wrote:
>
> To me, the question is "do we support higher order allocations, or not?".
>  Pretending we do, making a half-assed job of it, and then it not working
>  well under pressure is not helping anyone. I'm told, for instance, that
>  AMD64 requires > 4K stacks - that's pretty fundamental, as just one 
>  instance. I'd rather make Linux pretty bulletproof - the added feature
>  stuff is just a bonus that comes for free with that.

Well...  stacks are allocated with GFP_KERNEL, so we're reliable there.

It's the GFP_ATOMIC higher-order allocations which fail, and networking
copes with that.

I suspect this would all be a non-issue if the net drivers were using
__GFP_NOWARN ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
