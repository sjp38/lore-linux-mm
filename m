Message-ID: <456EC20D.4090406@yahoo.com.au>
Date: Thu, 30 Nov 2006 22:35:41 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
References: <20061129030655.941148000@menage.corp.google.com>	 <456E95C4.5020809@yahoo.com.au>	 <6599ad830611300039m334e276i9cb3141cc5358d00@mail.gmail.com>	 <456E9C90.4020909@yahoo.com.au>	 <6599ad830611300106w5f5deb60q6d83a684fd679d06@mail.gmail.com>	 <456EA28C.8070508@yahoo.com.au>	 <6599ad830611300145gae22510te7eaa63edf539ad1@mail.gmail.com>	 <456EAF4D.5000804@yahoo.com.au>	 <6599ad830611300240x388ef00s60183bc3a105ed2a@mail.gmail.com>	 <456EBACB.9080304@yahoo.com.au> <6599ad830611300323l40841241qaa39ee497c26769c@mail.gmail.com>
In-Reply-To: <6599ad830611300323l40841241qaa39ee497c26769c@mail.gmail.com>
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
>> But I'm not sure that there is a good reason to use the same
>> abstraction. Maybe there is, but I think it needs more discussion
>> (unless I missed something in the past couple of weeks were you
>> managed to get all memory resource controller groups to agree with
>> your fakenodes approach).
> 
> 
> No, not at all - but we've observed that:

I agree with your points and I'll add a couple more.

> a) people have been proposing interesting memory controller approaches
> for a long time, and haven't made a great deal of progress so far, so
> there's no indication than something is going to be agreed upon in the
> near future

a2) and it hasn't been because they've been getting their APIs wrong

> b) the cpusets and fake numa code provide a fairly serviceable
> coarse-grained memory controller, modulo a few missing features such
> as per-node reclaim/migration and auto-expansion (see my patch
> proposal hopefully tomorrow).

b2) and it doesn't mean that it can't be used with a decent API. Or
at least, you haven't yet shown that it can't.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
