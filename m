Message-ID: <456EA28C.8070508@yahoo.com.au>
Date: Thu, 30 Nov 2006 20:21:16 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
References: <20061129030655.941148000@menage.corp.google.com>	 <20061129033826.268090000@menage.corp.google.com>	 <456D23A0.9020008@yahoo.com.au>	 <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>	 <456E8A74.5080905@yahoo.com.au>	 <6599ad830611292357q745eb2f8y1ad9d4fb5a85c41d@mail.gmail.com>	 <456E95C4.5020809@yahoo.com.au>	 <6599ad830611300039m334e276i9cb3141cc5358d00@mail.gmail.com>	 <456E9C90.4020909@yahoo.com.au> <6599ad830611300106w5f5deb60q6d83a684fd679d06@mail.gmail.com>
In-Reply-To: <6599ad830611300106w5f5deb60q6d83a684fd679d06@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 11/30/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>> >
>> > Being able to say "try to move all memory from this node to this other
>> > set of nodes" seems like a generically useful thing even for other
>> > uses (e.g. hot unplug, general HPC numa systems, etc).
>>
>> AFAIK they do that in their higher level APIs (at least HPC numa does).
> 
> 
> Could you point me at an example?

kernel/cpuset.c:cpuset_migrate_mm

>> So your API could be some directive to consolidate? You could get
>> pretty accurate estimates with page statistics, as to whether it
>> can be done or not.
> 
> 
> Yes, and exposing those statistics (already available in
> /sys/device/system/node/node*/meminfo) and the low-level mechanism for
> migration are, to me, things that are appropriate for the kernel. I'm
> not sure what a specific "consolidation API" would look like, beyond
> the API that I'm already proposing (migrate memory from node X to
> nodes A,B,C)

How about "try to change the memory reservation charge of this
'container' from xMB to yMB"? Underneath that API, your fakenode
controller would do the node reclaim and consolidation stuff --
but it could be implemented completely differently in the case of
a different type of controller.

>> The cpusets code is definitely similar to what memory resource control
>> needs. I don't think that a resource control API needs to be tied to
>> such granular, hard limits as the fakenodes code provides though. But
>> maybe I'm wrong and it really would be acceptable for everyone.
> 
> 
> Ah. This isn't intended to be specifically a "resource control API".
> It's more intended to be an API that could be useful for certain kinds
> of resource control, but could also be generically useful.

If it is exporting any kind of implementation details, then it needs
to be justified with a specific user that can't be implemented in a
better way, IMO.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
