Message-ID: <456E8A74.5080905@yahoo.com.au>
Date: Thu, 30 Nov 2006 18:38:28 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
References: <20061129030655.941148000@menage.corp.google.com>	 <20061129033826.268090000@menage.corp.google.com>	 <456D23A0.9020008@yahoo.com.au> <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>
In-Reply-To: <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 11/28/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:

>> Can you not wire it up to your resource isolation
>> implementation in the kernel?
> 
> 
> This *is* the resource isolation implementation (plus the existing
> cpusets and fake-numa code). The intention is to expose just enough
> knobs/hooks to userspace that it can be handled there.

Yes, but when you migrate tasks between these containers, or when you
create/destroy them, then why can't you do the migration at that time?

>> ... yeah it would obviously be much nicer to do it in kernel space,
>> behind your higher level APIs.
> 
> 
> I don't think it would - keeping as much of the code as possible in
> userspace makes development and deployment much faster. We don't
> really have any higher-level APIs at this point - just userspace
> middleware manipulating cpusets.

We can't use that as an argument for the upstream kernel, but I
would believe that it is a good choice for google.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
