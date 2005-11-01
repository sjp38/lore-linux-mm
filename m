Message-ID: <43677E49.7060702@argo.co.il>
Date: Tue, 01 Nov 2005 16:40:09 +0200
From: Avi Kivity <avi@argo.co.il>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie><20051031055725.GA3820@w-mikek2.ibm.com><4365BBC4.2090906@yahoo.com.au> <20051030235440.6938a0e9.akpm@osdl.org> <27700000.1130769270@[10.10.2.4]>
In-Reply-To: <27700000.1130769270@[10.10.2.4]>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, kravetz@us.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:

>To me, the question is "do we support higher order allocations, or not?".
>Pretending we do, making a half-assed job of it, and then it not working
>well under pressure is not helping anyone. I'm told, for instance, that
>AMD64 requires > 4K stacks - that's pretty fundamental, as just one 
>instance. I'd rather make Linux pretty bulletproof - the added feature
>stuff is just a bonus that comes for free with that.
>  
>
This particular example doesn't warrant higher-order allocations. We can 
easily reserve 8GB of virtual space and map 8K stacks there. This is 
enough for 1M threads, and if you want more, there's plenty of virtual 
address space where those 8GB came from.

The other common examples (jumbo frames) can probably use 
scatter-gather, though that depends on the hardware.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
