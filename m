Message-ID: <3DA5D052.4020908@us.ibm.com>
Date: Thu, 10 Oct 2002 12:09:06 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch] Memory Binding API v0.3 2.5.41
References: <3DA4D3E4.6080401@us.ibm.com> <1034244381.3629.8.camel@localhost.localdomain> <1034248971.2044.118.camel@irongate.swansea.linux.org.uk> <20021010112844.GW12432@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Arjan van de Ven <arjanv@fenrus.demon.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Martin Bligh <mjbligh@us.ibm.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> At some point in the past, Matthew Dobson wrote:
> 
>>>>+asmlinkage long sys_mem_setbinding(pid_t pid, unsigned long memblks, 
>>>>+				    unsigned int behavior)
>>>
> 
> On Thu, 2002-10-10 at 11:06, Arjan van de Ven wrote:
> 
>>>Do you really think exposing low level internals as memory layout / zone
>>>split up to userspace is a good idea ? (and worth it given that the VM
>>>already has a cpu locality preference?)
>>
> 
> On Thu, Oct 10, 2002 at 12:22:51PM +0100, Alan Cox wrote:
> 
>>At least in the embedded world that level is a good idea. I'm not sure
>>about the syscall interface. An "unsigned long" mask of blocks sounds
>>like a good way to ensure a broken syscall in the future
> Seconded wrt. memblk bitmask interface.
Glad to have your support!  :)

> Also, I've already privately replied with some of my stylistic concerns,
> including things like the separability of the for_each_in_zonelist()
> cleanup bundled into the patch and a typedef or so.
Some very good points in your email.  Most (if not all) will be 
incorporated in v0.4 (later today or tomorrow).

Cheers!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
