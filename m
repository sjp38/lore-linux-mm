Message-ID: <3DA5CE88.7020400@us.ibm.com>
Date: Thu, 10 Oct 2002 12:01:28 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch] Memory Binding API v0.3 2.5.41
References: <3DA4D3E4.6080401@us.ibm.com> <1034244381.3629.8.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@fenrus.demon.nl>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Martin Bligh <mjbligh@us.ibm.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Arjan van de Ven wrote:
>>+/**
>>+ * sys_mem_setbinding - set the memory binding of a process
>>+ * @pid: pid of the process
>>+ * @memblks: new bitmask of memory blocks
>>+ * @behavior: new behavior
>>+ */
>>+asmlinkage long sys_mem_setbinding(pid_t pid, unsigned long memblks, 
>>+				    unsigned int behavior)
>>+{
> 
> Do you really think exposing low level internals as memory layout / zone
> split up to userspace is a good idea ? (and worth it given that the VM
> already has a cpu locality preference?)
Yes, I actually do.  If userspace processes/users don't care about the 
memory/zone layout, they don't have to look.  But if they *do* care, 
they should be able to find out, and not be left in the proverbial dark. 
  Embedded systems will care, as will really large NUMA/Discontig 
systems.  As with some other patches, this functionality will not affect 
the average user on the average computer...  They are useful for really 
small systems, and really large systems, however.

> I'd much rather see the VM have an arch-specified "cost" for getting
> memory from not-the-prefered zones than exposing all this stuff to
> userspace and depending on userspace to do the right thing.... it's the
> kernel's task to abstract the low level details of the hardware after
> all.
The arch-specified 'cost' is also a good idea.  Some of the topology 
stuff I'm working on will allow that sort of interface as well.  And 
this patch does not 'depend' on userspace to do the right thing.  The 
patch does not alter the default VM behavior unless userspace 
*specifically* asks to alter it.

Cheers!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
