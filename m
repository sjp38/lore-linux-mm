Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4F3455F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 07:20:04 -0400 (EDT)
Message-ID: <49D9E53D.5080807@redhat.com>
Date: Mon, 06 Apr 2009 14:19:25 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v2
References: <1238855722-32606-1-git-send-email-ieidus@redhat.com> <200904061704.50052.nickpiggin@yahoo.com.au>
In-Reply-To: <200904061704.50052.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Sunday 05 April 2009 01:35:18 Izik Eidus wrote:
>
>   
>> This driver is very useful for KVM as in cases of runing multiple guests
>> operation system of the same type.
>> (For desktop work loads we have achived more than x2 memory overcommit
>> (more like x3))
>>     
>
> Interesting that it is a desirable workload to have multiple guests each
> running MS office.
>   

This numbers are took from such workload, it is some kind of weird 
script that keep opening Word / Excel and write there like a user...
I think in addition it open internet explorer and enter to random sites...
I can search for the script if wanted...

> I wonder, can windows enter a paravirtualised guest mode for KVM? And can
> you detect page allocation/freeing events?
>   

I Dont know.

>  
>   
>> This driver have found users other than KVM, for example CERN,
>> Fons Rademakers:
>> "on many-core machines we run one large detector simulation program per core.
>> These simulation programs are identical but run each in their own process and
>> need about 2 - 2.5 GB RAM.
>> We typically buy machines with 2GB RAM per core and so have a problem to run
>> one of these programs per core.
>> Of the 2 - 2.5 GB about 700MB is identical data in the form of magnetic field
>> maps, detector geometry, etc.
>> Currently people have been trying to start one program, initialize the geometry
>> and field maps and then fork it N times, to have the data shared.
>> With KSM this would be done automatically by the system so it sounded extremely
>> attractive when Andrea presented it."
>>     
>
> They should use a shared memory segment, or MAP_ANONYMOUS|MAP_SHARED etc.
> Presumably they will probably want to control it to interleave it over
> all numa nodes and use hugepages for it. It would be very little work.
>   

Agree about that, dont know their application to much, i know they had 
problems to do it.

>  
>   
>> I am sending another seires of patchs for kvm kernel and kvm-userspace
>> that would allow users of kvm to test ksm with it.
>> The kvm patchs would apply to Avi git tree.
>>     

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
