Date: Sat, 08 Feb 2003 21:22:12 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: vmalloc errors in 2.4.20
Message-ID: <8050000.1044768131@[10.10.2.4]>
In-Reply-To: <20030209043937.7134.qmail@web21309.mail.yahoo.com>
References: <20030209043937.7134.qmail@web21309.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sandeep uttamchandani <sm_uttamchandani@yahoo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The linux kernel 2.4.20 seems to have problems with
> vmalloc. Here is what I did:
> 
> In my driver, I try to allocate a buffer of size 512K
> using vmalloc ( kmalloc cannot allocate more than
> 128K). It generates a kernel oops message saying that
> the virtual memory cannot be allocated.
> 
> I suspect there is a problem with the address range
> defined for vmalloc namely by VMALLOC_START and
> VMALLOC_END. 
> 
> Any thoughts of what might be going-on ? 

Not really. But why don't you just call alloc_pages instead?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
