Message-ID: <3E3EFE94.2020203@us.ibm.com>
Date: Mon, 03 Feb 2003 15:43:16 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: Re: [question] shm_nattch in sys_shmat?
References: <3E3AFA3A.6050205@us.ibm.com> <ov4r7lf8mm.fsf@sap.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

Christoph Rohland wrote:
> Hi Matthew,
> 
> On Fri, 31 Jan 2003, Matthew Dobson wrote:
> 
>>	sys_shmat, does in fact increment shm_nattch, but only to
>>	decrement it again a few lines later, as seen in this code
>>	snippet.  Can anyone please explain why this is?
> 
> 
> sys_shmat temporarily increases shm_nattch to make sure it's never zero:
> 
> 
>> >>>	shp->shm_nattch++;
> 
> 
> Make sure shm_nattch is greater than zero.
> 
> 
>> >	user_addr = (void*) do_mmap (file, addr, size, prot,
> 
> 
> map the segment which increments shm_nattch in shm_mmap accounting for
> the actual mapping
> 
> 
>> >>>	shp->shm_nattch--;
> 
> 
> Correct it again.
> 
> Greetings
> 		Christoph

Ah ha...   I hadn't followed the do_mmap call chain deep enough to 
notice that it would call the shm_mmap call through the f_op function 
pointer.  Thanks for pointing that out.  It makes much more sense now. 
A small comment in there would make it *much* more obvious what is going on.

Cheers!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
