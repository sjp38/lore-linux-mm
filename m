Received: from fujitsu1.fujitsu.com (localhost [127.0.0.1])
	by fujitsu1.fujitsu.com (8.12.10/8.12.9) with ESMTP id i5P3Bud6020864
	for <linux-mm@kvack.org>; Thu, 24 Jun 2004 20:11:56 -0700 (PDT)
Date: Thu, 24 Jun 2004 20:11:37 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Re: [Lhms-devel] Re: Merging Nonlinear and Numa style memory hotplug
In-Reply-To: <1088116621.3918.1060.camel@nighthawk>
References: <20040624135838.F009.YGOTO@us.fujitsu.com> <1088116621.3918.1060.camel@nighthawk>
Message-Id: <20040624194557.F02B.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Linux-Node-Hotplug <lhns-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, "BRADLEY CHRISTIANSEN [imap]" <bradc1@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I understand this idea at last.
Section size of DLPAR of PPC is only 16MB.
But kmalloc area of virtual address have to be contigous 
even if the area is divided 16MB physically.
Dave-san's implementation (it was for IA32) was same index between 
phys_section and mem_section. So, I was confused.

> pfn_to_page(unsigned long pfn)
> {
>        return
> &mem_section[phys_section[pfn_to_section(pfn)]].mem_map[section_offset_pfn(pfn)];
> }
> 

But, I suppose this translation might be too complex.
I worry that many person don't like this which is cause of
performance deterioration.
Should this translation be in common code?

Bye.

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
