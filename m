Message-ID: <46CE7211.2010708@redhat.com>
Date: Fri, 24 Aug 2007 01:52:17 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: Drop caches - is this safe behavior?
References: <bd9320b30708231645x3c6524efi55dd2cf7b1a9ba51@mail.gmail.com>	 <bd9320b30708231707l67d2d9d0l436a229bd77a86f@mail.gmail.com>	 <46CE3617.6000708@redhat.com>	 <1187930857.6406.12.camel@norville.austin.ibm.com>	 <46CE69DE.9040807@redhat.com> <bd9320b30708232227v1b297a42pd9b20e04aef758d7@mail.gmail.com>
In-Reply-To: <bd9320b30708232227v1b297a42pd9b20e04aef758d7@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mike <mike503@gmail.com>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mike wrote:
> On 8/23/07, Chris Snook <csnook@redhat.com> wrote:
>> Mike --
>>
>>        Try Dave's suggestion to increase vm.vfs_cache_pressure.  drop_pages
>> should never be needed, regardless of which caches you're dropping.
>>
>>        -- Chris
>>
> 
> thanks all. i will try it on one of the machines and see how it performs.
> 
> this is an opteron 1.8ghz (amd64), ubuntu, latest stable linux kernel,
> 3 gigs of ram (just FYI) - SATA disk.
> 
> i thought i'd do it every 5 minutes not because of a horrible memory
> leak that fast, but figured "why not just free up all RAM as often as
> possible"

I think the caches you had in mind were the ones that would be dropped 
by echoing '1' into /proc/sys/vm/drop_caches, not the ones that would be 
dropped by echoing '2' into it.  If you were dropping pagecache every 
five minutes, it would kill your performance as you described.  As for 
the question of safety, '3' should also be safe, but terrible for 
performance, as it does all the harm of '1', plus some.

> when you said "sar" are you talking about this:
> 
> atsar - system activity reporter
> Description: system activity reporter
>  Monitor system resources such as CPU, network, memory & disk I/O, and
>  record data for later analysis

I'm not familiar with the "atsar" implementation, but it appears to be 
an alternate implementation of the same thing.  It's an excellent tool 
for long-term workload profiling.

	-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
