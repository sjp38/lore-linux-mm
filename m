Message-ID: <456E95C4.5020809@yahoo.com.au>
Date: Thu, 30 Nov 2006 19:26:44 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
References: <20061129030655.941148000@menage.corp.google.com>	 <20061129033826.268090000@menage.corp.google.com>	 <456D23A0.9020008@yahoo.com.au>	 <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>	 <456E8A74.5080905@yahoo.com.au> <6599ad830611292357q745eb2f8y1ad9d4fb5a85c41d@mail.gmail.com>
In-Reply-To: <6599ad830611292357q745eb2f8y1ad9d4fb5a85c41d@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 11/29/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>
>> Yes, but when you migrate tasks between these containers, or when you
>> create/destroy them, then why can't you do the migration at that time?
> 
> 
> ?
> 
> The migration that I'm envisaging is going to occur when either:
> 
> - we're trying to move a job to a different real numa node because,
> say, a new job has started that needs the whole of a node to itself,
> and we need to clear space for it.

So migrate at this point.

> - we're trying to compact the memory usage of a job, when it has
> plenty of free space in each of its nodes, and we can fit all the
> memory into a smaller set of nodes.

Or reclaim at this point.

>> We can't use that as an argument for the upstream kernel, but I
>> would believe that it is a good choice for google.
>>
> 
> I would have thought that providing userspace just enough hooks to do
> what it needs to do, and not mandating higher-level constructs is
> exactly the philosophy of the linux kernel. Hence, e.g. providing

Yes, but without exposing implementation to userspace, where possible.

The ultimate would be to devise an API which is usable by your patch,
as well as the other resource control mechanisms going around. If
userspace has to know that you've implemented memory control with
"fake nodes", then IMO something has gone wrong.

> efficient building blocks like sendfile and a threaded network stack,
> faster therading with NPTL and a very limited static-file webserver
> (TUX, even though it's not in the mainline) and leaving the complex
> bits of webserving to userspace.

I don't see the similarity with sendfile+TUX. I don't think putting an
explicit container / resource controller API in the kernel is even
anything like TUX in the kernel, let alone apache in kernel.

> Things like deciding which containers should be using which nodes, and
> directing the kernel appropriately, is the job of userspace, not
> kernelspace, since there are lots of possible ways of making those
> decisions.

I disagree.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
