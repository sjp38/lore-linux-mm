From: "Ray Bryant" <raybry@mpdtxmail.amd.com>
Subject: Re: [PATCH/RFC] Shared page tables
Date: Fri, 13 Jan 2006 16:34:23 -0600
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <43C73767.5060506@us.ibm.com>
In-Reply-To: <43C73767.5060506@us.ibm.com>
MIME-Version: 1.0
Message-ID: <200601131634.24913.raybry@mpdtxmail.amd.com>
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brian Twichell <tbrian@us.ibm.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, slpratt@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thursday 12 January 2006 23:15, Brian Twichell wrote:

> Hi,
>
> We evaluated page table sharing on x86_64 and ppc64 setups, using a
> database OLTP workload.  In both cases, 4-way systems with 64 GB of memory
> were used.
>
> On the x86_64 setup, page table sharing provided a 25% increase in
> performance,
> when the database buffers were in small (4 KB) pages.  In this case,
> over 14 GB
> of memory was freed, that had previously been taken up by page tables.
> In the
> case that the database buffers were in huge (2 MB) pages, page table
> sharing provided a 4% increase in performance.
>

Brian,

Is that 25%-50% percent of overall performance (e. g. transaction throughput), 
or is this a measurement of, say, DB process startup times, or what?   It 
seems to me that the impact of the shared page table patch would mostly be 
noticed at address space construction/destruction times, and for a big OLTP 
workload, the processes are probably built once and stay around forever, no?

If the performance improvement is in overall throughput, do you understand why 
the impact would be so large?   TLB reloads?   I don't understand why one 
would see that kind of overall performance improvement, but I could be 
overlooking something.   (Could very likely be overlooking something...:-) )

Oh, and yeah, was this an AMD x86_64 box or what?
-- 
Ray Bryant
AMD Performance Labs                   Austin, Tx
512-602-0038 (o)                 512-507-7807 (c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
