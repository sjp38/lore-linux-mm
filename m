Subject: Re: [Lhms-devel] Re: Merging Nonlinear and Numa style memory
	hotplug
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040625121110.2937.YGOTO@us.fujitsu.com>
References: <20040625114720.2935.YGOTO@us.fujitsu.com>
	 <1088189973.29059.231.camel@nighthawk>
	 <20040625121110.2937.YGOTO@us.fujitsu.com>
Content-Type: text/plain
Message-Id: <1088196579.29059.344.camel@nighthawk>
Mime-Version: 1.0
Date: Fri, 25 Jun 2004 13:49:40 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Linux-Node-Hotplug <lhns-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, "BRADLEY CHRISTIANSEN [imap]" <bradc1@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-06-25 at 13:45, Yasunori Goto wrote:
> > > Are you sure that all architectures need phys_section?
> > 
> > You don't *need* it, but the alternative is a scan of the mem_section[]
> > array, which would be much, much slower.
> > 
> > Do you have an idea for an alternate implementation?
> 
> I didn't find that scan of the mem_section[] is necessary.
> I thought just that mem_section index = phys_section index.
> May I ask why scan of mem_section is necessary?
> I might still have misunderstood something.

For now, the indexes happen to be the same.  However, for discontiguous
memory systems, this will not be the case

mem | phys
----+-----
    | 
    | 
    | 
    | 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
