Received: from fujitsu1.fujitsu.com (localhost [127.0.0.1])
	by fujitsu1.fujitsu.com (8.12.10/8.12.9) with ESMTP id i5PImRd6014130
	for <linux-mm@kvack.org>; Fri, 25 Jun 2004 11:48:27 -0700 (PDT)
Date: Fri, 25 Jun 2004 11:48:07 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Re: [Lhms-devel] Re: Merging Nonlinear and Numa style memory hotplug
In-Reply-To: <1088133541.3918.1348.camel@nighthawk>
References: <20040624194557.F02B.YGOTO@us.fujitsu.com> <1088133541.3918.1348.camel@nighthawk>
Message-Id: <20040625114720.2935.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Linux-Node-Hotplug <lhns-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, "BRADLEY CHRISTIANSEN [imap]" <bradc1@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> 
> > Should this translation be in common code?
> 
> What do you mean by common code?  It should be shared by all
> architectures.

If physical memory chunk size is larger than the area which
should be contiguous like IA32's kmalloc, 
there is no merit in this code.
So, I thought only mem_section is enough.
But I don't know about other architecutures yet and I'm not sure.

Are you sure that all architectures need phys_section?

Bye.
-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
