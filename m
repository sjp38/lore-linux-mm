Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 033FD6B7396
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:23:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b3so9586091edi.0
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:23:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13sor10936286edm.0.2018.12.05.01.23.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 01:23:20 -0800 (PST)
Date: Wed, 5 Dec 2018 09:23:19 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/2] core-api/memory-hotplug.rst: divide Locking Internal
 section by different locks
Message-ID: <20181205092319.nl772drzhpezcgt2@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181205023426.24029-1-richard.weiyang@gmail.com>
 <20181205023426.24029-2-richard.weiyang@gmail.com>
 <570e4080-8c35-3de4-9ee6-8a508a2a4649@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <570e4080-8c35-3de4-9ee6-8a508a2a4649@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, osalvador@suse.de, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 05, 2018 at 09:08:47AM +0100, David Hildenbrand wrote:
>On 05.12.18 03:34, Wei Yang wrote:
>> Currently locking for memory hotplug is a little complicated.
>> 
>> Generally speaking, we leverage the two global lock:
>> 
>>   * device_hotplug_lock
>>   * mem_hotplug_lock
>> 
>> to serialise the process.
>> 
>> While for the long term, we are willing to have more fine-grained lock
>> to provide higher scalability.
>> 
>> This patch divides Locking Internal section based on these two global
>> locks to help readers to understand it. Also it adds some new finding to
>> enrich it.
>> 
>> [David: words arrangement]
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  Documentation/core-api/memory-hotplug.rst | 27 ++++++++++++++++++++++++---
>>  1 file changed, 24 insertions(+), 3 deletions(-)
>> 
>> diff --git a/Documentation/core-api/memory-hotplug.rst b/Documentation/core-api/memory-hotplug.rst
>> index de7467e48067..95662b283328 100644
>> --- a/Documentation/core-api/memory-hotplug.rst
>> +++ b/Documentation/core-api/memory-hotplug.rst
>> @@ -89,6 +89,20 @@ NOTIFY_STOP stops further processing of the notification queue.
>>  Locking Internals
>>  =================
>>  
>> +There are three locks involved in memory-hotplug, two global lock and one local
>> +lock:
>> +
>> +- device_hotplug_lock
>> +- mem_hotplug_lock
>> +- device_lock
>> +
>
>Do we really only ever use these three and not anything else when
>adding/removing/onlining/offlining memory?
>
>(I am thinking e.g. about pgdat_resize_lock)

Yes there are more than those three, pgdat_resize_lock is one of them.

>
>If so, you should phrase that maybe more generally Or add more details :)

Yep, while I don't get a whole picture about the pgdat_resize_lock. The
usage of this lock scatter in many places.

>
>"In addition to fine grained locks like pgdat_resize_lock, there are
>three locks involved ..."
>

Sounds better :-)

-- 
Wei Yang
Help you, Help me
