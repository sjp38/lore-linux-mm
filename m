Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i5PKjkNv027558
	for <linux-mm@kvack.org>; Fri, 25 Jun 2004 13:45:46 -0700 (PDT)
Date: Fri, 25 Jun 2004 13:45:30 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Re: [Lhms-devel] Re: Merging Nonlinear and Numa style memory hotplug
In-Reply-To: <1088189973.29059.231.camel@nighthawk>
References: <20040625114720.2935.YGOTO@us.fujitsu.com> <1088189973.29059.231.camel@nighthawk>
Message-Id: <20040625121110.2937.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Linux-Node-Hotplug <lhns-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, "BRADLEY CHRISTIANSEN [imap]" <bradc1@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> > Are you sure that all architectures need phys_section?
> 
> You don't *need* it, but the alternative is a scan of the mem_section[]
> array, which would be much, much slower.
> 
> Do you have an idea for an alternate implementation?

I didn't find that scan of the mem_section[] is necessary.
I thought just that mem_section index = phys_section index.
May I ask why scan of mem_section is necessary?
I might still have misunderstood something.


-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
