Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 805946B004D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 04:39:21 -0500 (EST)
Message-ID: <50A0C2F2.6060100@redhat.com>
Date: Mon, 12 Nov 2012 17:35:46 +0800
From: Dave Young <dyoung@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Add a test program for variable page sizes in mmap/shmget
 v2
References: <1352408486-4318-1-git-send-email-andi@firstfloor.org> <20121108132946.c2b9e8b7.akpm@linux-foundation.org>
In-Reply-To: <20121108132946.c2b9e8b7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On 11/09/2012 05:29 AM, Andrew Morton wrote:

> On Thu,  8 Nov 2012 13:01:26 -0800
> Andi Kleen <andi@firstfloor.org> wrote:
> 
>> From: Andi Kleen <ak@linux.intel.com>
>>
>> Not hooked up to the harness so far, because it usually needs
>> special boot options for 1GB pages.
> 
> This isn't the case from my reading: we *can* hook it up now?
> 
>> index b336b24..7300d07 100644
>> --- a/tools/testing/selftests/vm/Makefile
>> +++ b/tools/testing/selftests/vm/Makefile
>> @@ -1,9 +1,9 @@
>>  # Makefile for vm selftests
>>  
>>  CC = $(CROSS_COMPILE)gcc
>> -CFLAGS = -Wall -Wextra
>> +CFLAGS = -Wall
> 
> Why this?  It doesn't change anything with my gcc so I think
> I'll revert that.
> 
>>
>> ...
>>
> 
> Also...
> 
> I just tried a `make run_vmtests' and it fell on its face. 
> There's a little comment in there saying "please run as root", but we
> don't *want* that.  The selftests should be runnable as non-root and
> should, where unavoidable, emit a warning and proceed if elevated
> permissions are required.


Hi andrew:
below code need root, I agree warning in case non-root is good, If you
like I can fix it.

echo $(( $lackpgs + $nr_hugepgs )) > /proc/sys/vm/nr_hugepages

> 
> I tried running it as root and my workstation hung, requiring a reboot.
> Won't be doing that again.
> 
> Dave, could you please have a dig at this sometime?


I can not reproduce the hang, will keep an eye on this.

-- 
Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
