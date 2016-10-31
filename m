Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49BA66B026A
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 07:59:21 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 128so32604866oih.1
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 04:59:21 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id r130si16995478oig.145.2016.10.31.04.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 04:59:20 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id i127so11347651oia.0
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 04:59:20 -0700 (PDT)
Subject: Re: Rewording language in mbind(2) to "threads" not "processes"
References: <f3c4ca9d-a880-5244-e06e-db4725e4d945@gmail.com>
 <20161025154050.GA3186@home>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <46a8d808-7ee1-f58c-ff3c-7786cc127de9@gmail.com>
Date: Mon, 31 Oct 2016 12:59:16 +0100
MIME-Version: 1.0
In-Reply-To: <20161025154050.GA3186@home>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: mtk.manpages@gmail.com, Christoph Lameter <cl@linux.com>, mhocko@kernel.org, mgorman@techsingularity.net, a.p.zijlstra@chello.nl, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, Brice Goglin <Brice.Goglin@inria.fr>

On 10/25/2016 05:40 PM, Piotr Kwapulinski wrote:
> Hi Michael,
> 
> I spent a couple of hours trying to review your patch. Unfortunately
> nowadays I spend no more than an hour per day for whole my linux
> kernel activity. It may take longer time for me to review it.
> This patch touches some areas of the kernel I'm still not an expert of
> (though I'm learning a lot). I'll review (and possibly fix) it ASAP.

Okay, Piotr, Thanks. If you do eventually have some input, that would
be great, but I understand you are time constrained.

Cheers,

Michael


> On Thu, Oct 13, 2016 at 10:38:33AM +0200, Michael Kerrisk (man-pages) wrote:
>> Christoph, Piotr, and Brice
>>
>> Since you (Christoph and Piotr) helped with documenting MPOL_LOCAL 
>> just recently, I wonder if I might ask you to review a patch that I 
>> propose for the mbind(2) manual page.
>>
>> As far as I understand, memory policy, as set by set_mempolicy(2)
>> is a per-thread attribute. The set_mempolicy(2) and get_mempolicy(2)
>> pages already reflect this, thanks to a patch from Brice last year.
>>
>> However, such changes were not made in the mbind(2) page.
>> I wonder if I could ask you (and Brice, and anyone who's willing)
>> to look at the patch that I propose below to remedy this. (There are 
>> a couple questions "???" that I've injected in the patch.) Is it okay?
>>
>> Cheers,
>>
>> Michael
>>
>>
>> diff --git a/man2/mbind.2 b/man2/mbind.2
>> index a5f26e2..9494854 100644
>> --- a/man2/mbind.2
>> +++ b/man2/mbind.2
>> @@ -75,16 +75,16 @@ page in the kernel containing all zeros.
>>  For a file mapped with
>>  .BR MAP_PRIVATE ,
>>  an initial read access will allocate pages according to the
>> -process policy of the process that causes the page to be allocated.
>> -This may not be the process that called
>> +memory policy of the thread that causes the page to be allocated.
>> +This may not be the thread that called
>>  .BR mbind ().
>>  
>>  The specified policy will be ignored for any
>>  .B MAP_SHARED
>>  mappings in the specified memory range.
>> -Rather the pages will be allocated according to the process policy
>> -of the process that caused the page to be allocated.
>> -Again, this may not be the process that called
>> +Rather the pages will be allocated according to the memory policy
>> +of the thread that caused the page to be allocated.
>> +Again, this may not be the thread that called
>>  .BR mbind ().
>>  
>>  If the specified memory range includes a shared memory region
>> @@ -100,7 +100,10 @@ If, however, the shared memory region was created with the
>>  .B SHM_HUGETLB
>>  flag,
>>  the huge pages will be allocated according to the policy specified
>> -only if the page allocation is caused by the process that calls
>> +only if the page allocation is caused by the thread that calls
>> +.\"
>> +.\" ??? Is it correct to change "process" to "thread" in the preceding line?
>> +.\"
>>  .BR mbind ()
>>  for that region.
>>  
>> @@ -146,15 +149,15 @@ A nonempty
>>  specifies physical node IDs.
>>  Linux does not remap the
>>  .I nodemask
>> -when the process moves to a different cpuset context,
>> -nor when the set of nodes allowed by the process's
>> +when the thread moves to a different cpuset context,
>> +nor when the set of nodes allowed by the thread's
>>  current cpuset context changes.
>>  .TP
>>  .BR MPOL_F_RELATIVE_NODES " (since Linux-2.6.26)"
>>  A nonempty
>>  .I nodemask
>>  specifies node IDs that are relative to the set of
>> -node IDs allowed by the process's current cpuset.
>> +node IDs allowed by the thread's current cpuset.
>>  .PP
>>  .I nodemask
>>  points to a bit mask of nodes containing up to
>> @@ -178,7 +181,7 @@ argument is ignored.
>>  Where a
>>  .I nodemask
>>  is required, it must contain at least one node that is on-line,
>> -allowed by the process's current cpuset context
>> +allowed by the thread's current cpuset context
>>  (unless the
>>  .B MPOL_F_STATIC_NODES
>>  mode flag is specified),
>> @@ -194,10 +197,10 @@ mode requests that any nondefault policy be removed,
>>  restoring default behavior.
>>  When applied to a range of memory via
>>  .BR mbind (),
>> -this means to use the process policy,
>> +this means to use the thread memory policy,
>>  which may have been set with
>>  .BR set_mempolicy (2).
>> -If the mode of the process policy is also
>> +If the mode of the thread memory policy is also
>>  .BR MPOL_DEFAULT ,
>>  the system-wide default policy will be used.
>>  The system-wide default policy allocates
>> @@ -268,13 +271,13 @@ If the "local node" is low on free memory,
>>  the kernel will try to allocate memory from other nodes.
>>  The kernel will allocate memory from the "local node"
>>  whenever memory for this node is available.
>> -If the "local node" is not allowed by the process's current cpuset context,
>> +If the "local node" is not allowed by the thread's current cpuset context,
>>  the kernel will try to allocate memory from other nodes.
>>  The kernel will allocate memory from the "local node" whenever
>> -it becomes allowed by the process's current cpuset context.
>> +it becomes allowed by the thread's current cpuset context.
>>  By contrast,
>>  .B MPOL_DEFAULT
>> -reverts to the policy of the process (which may be set via
>> +reverts to the memory policy of the thread (which may be set via
>>  .BR set_mempolicy (2));
>>  that policy may be something other than "local allocation".
>>  .PP
>> @@ -300,7 +303,10 @@ is specified in
>>  .IR flags ,
>>  then the kernel will attempt to move all the existing pages
>>  in the memory range so that they follow the policy.
>> -Pages that are shared with other processes will not be moved.
>> +Pages that are shared with other threads will not be moved.
>> +.\"
>> +.\" ??? Is it correct to change "processes" to "threads" in the preceding line?
>> +.\"
>>  If
>>  .B MPOL_MF_STRICT
>>  is also specified, then the call will fail with the error
>> @@ -312,8 +318,11 @@ If
>>  is passed in
>>  .IR flags ,
>>  then the kernel will attempt to move all existing pages in the memory range
>> -regardless of whether other processes use the pages.
>> -The calling process must be privileged
>> +regardless of whether other threads use the pages.
>> +.\"
>> +.\" ??? Is it correct to change "processes" to "threads" in the preceding line?
>> +.\"
>> +The calling thread must be privileged
>>  .RB ( CAP_SYS_NICE )
>>  to use this flag.
>>  If
>> @@ -383,7 +392,7 @@ specifies one or more node IDs that are
>>  greater than the maximum supported node ID.
>>  Or, none of the node IDs specified by
>>  .I nodemask
>> -are on-line and allowed by the process's current cpuset context,
>> +are on-line and allowed by the thread's current cpuset context,
>>  or none of the specified nodes contain memory.
>>  Or, the
>>  .I mode
>> @@ -440,14 +449,14 @@ When
>>  .B MPOL_DEFAULT
>>  is specified for
>>  .BR set_mempolicy (2),
>> -the process's policy reverts to system default policy
>> +the thread's memory policy reverts to the system default policy
>>  or local allocation.
>>  When
>>  .B MPOL_DEFAULT
>>  is specified for a range of memory using
>>  .BR mbind (),
>>  any pages subsequently allocated for that range will use
>> -the process's policy, as set by
>> +the thread's memory policy, as set by
>>  .BR set_mempolicy (2).
>>  This effectively removes the explicit policy from the
>>  specified range, "falling back" to a possibly nondefault
>>
>> -- 
>> Michael Kerrisk
>> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
>> Linux/UNIX System Programming Training: http://man7.org/training/
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
