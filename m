Message-ID: <4325D150.6040505@kolumbus.fi>
Date: Mon, 12 Sep 2005 22:04:48 +0300
From: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] i386: consolidate discontig functions into normal
 ones
References: <20050912175319.7C51CF96@kernel.beaverton.ibm.com>
In-Reply-To: <20050912175319.7C51CF96@kernel.beaverton.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

>There are quite a few functions in i386's discontig.c which are
>actually NUMA-specific, not discontigmem.  They are also very
>similar to the generic, flat functions found in setup.c.
>
>This patch takes the versions in setup.c and makes them work
>for both NUMA and non-NUMA cases.  In the process, quite a
>few nasty #ifdef and externs can be removed.
>
>One of the main mechanisms to do this is that highstart_pfn
>and highend_pfn are now gone, replaced by node_start/end_pfn[].
>However, this has no real impact on storage space, because
>those arrays are declared with a length of MAX_NUMNODES, which
>is 1 when NUMA is off.
>
>
>  
>
I think you allocate remap pages for nothing in the flatmem case for 
node0...those aren't used for the mem map in !NUMA.

--Mika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
