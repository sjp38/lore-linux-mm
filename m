Subject: Re: [Lhms-devel] Re: Merging Nonlinear and Numa style memory
	hotplug
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040625114720.2935.YGOTO@us.fujitsu.com>
References: <20040624194557.F02B.YGOTO@us.fujitsu.com>
	 <1088133541.3918.1348.camel@nighthawk>
	 <20040625114720.2935.YGOTO@us.fujitsu.com>
Content-Type: text/plain
Message-Id: <1088189973.29059.231.camel@nighthawk>
Mime-Version: 1.0
Date: Fri, 25 Jun 2004 11:59:33 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Linux-Node-Hotplug <lhns-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, "BRADLEY CHRISTIANSEN [imap]" <bradc1@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-06-25 at 11:48, Yasunori Goto wrote:
> > 
> > > Should this translation be in common code?
> > 
> > What do you mean by common code?  It should be shared by all
> > architectures.
> 
> If physical memory chunk size is larger than the area which
> should be contiguous like IA32's kmalloc, 
> there is no merit in this code.
> So, I thought only mem_section is enough.
> But I don't know about other architecutures yet and I'm not sure.
> 
> Are you sure that all architectures need phys_section?

You don't *need* it, but the alternative is a scan of the mem_section[]
array, which would be much, much slower.

Do you have an idea for an alternate implementation?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
