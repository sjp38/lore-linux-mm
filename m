Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3PH41T6113674
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 17:04:01 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3PH56Kp118924
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 19:05:06 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3PH40BS019737
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 19:04:00 +0200
Subject: Re: Page host virtual assist patches.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <20060425092928.292f3662.akpm@osdl.org>
References: <20060424123412.GA15817@skybase>
	 <20060424180138.52e54e5c.akpm@osdl.org> <444DCD87.2030307@yahoo.com.au>
	 <1145953914.5282.21.camel@localhost>
	 <20060425013712.365892c2.akpm@osdl.org>
	 <1145961867.5282.46.camel@localhost>
	 <20060425092928.292f3662.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 25 Apr 2006 19:04:04 +0200
Message-Id: <1145984644.30426.5.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-25 at 09:29 -0700, Andrew Morton wrote:
> > Yes we can. We even had some patches for sharing the kernel text between
> > virtual machines. But the kernel text is only a small part of the memory
> > that gets accessed for a vmscan operation.
> > 
> 
> And the bulk of the rest will be accesses to mem_map[].  I guess the hva
> patches still require that each guests's mem_map[] be in host memory, but
> not necessarily in guest memory?

The host does not need the mem_map information. The state information of
the guest pages is passed to the host by use of an instruction. It is
stored in the host page table for the guest (well actually in the PGSTE
which is the virtualization extension of the page table entry). The host
does not need any data from the guest memory for the decision to discard
a page, only the state information. Just like the linux kernel does not
need any user space data to swap a user page except for the page
content, with the difference that the host can discard the page based on
the state information.

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
