Date: Wed, 15 Dec 2004 07:08:46 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <690790000.1103123325@[10.10.2.4]>
In-Reply-To: <20041215071734.GO27225@wotan.suse.de>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com> <9250000.1103050790@flay> <20041214191348.GA27225@wotan.suse.de> <19030000.1103054924@flay> <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <20041215040854.GC27225@wotan.suse.de> <686170000.1103094885@[10.10.2.4]> <20041215071734.GO27225@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--Andi Kleen <ak@suse.de> wrote (on Wednesday, December 15, 2004 08:17:34 +0100):

> On Tue, Dec 14, 2004 at 11:14:46PM -0800, Martin J. Bligh wrote:
>> Well hold on a sec. We don't need to use the hugepages pool for this,
>> do we? This is the same as using huge page mappings for the whole of
>> kernel space on ia32. As long as it's a kernel mapping, and 16MB aligned
>> and contig, we get it for free, surely?
> 
> The whole point of the patch is to not use the direct mapping, but
> use a different interleaved mapping on NUMA machines to spread
> the memory out over multiple nodes.

Right, I know it's not there pre-existant - I was thinking of frigging it 
by hand though, rather than using the hugepage pool infrastructure.

>> > Using other page sizes would be probably tricky because the 
>> > linux VM can currently barely deal with two page sizes.
>> > I suspect handling more would need some VM infrastructure effort
>> > at least in the changed port. 
>> 
>> For the general case I'd agree. But this is a setup-time only tweak
>> of the static kernel mapping, isn't it?
> 
> It's probably not impossible, just lots of ugly special cases.
> e.g. how about supporting it for /proc/kcore etc? 

Hmmm. Yes, not considered those. 

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
