Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8576B0387
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 01:55:15 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id u8so183039583ywu.0
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 22:55:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g9si5459549pln.170.2017.02.13.22.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 22:55:14 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1E6rWsW144776
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 01:55:13 -0500
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com [125.16.236.5])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28kk8nd2nq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 01:55:13 -0500
Received: from localhost
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 14 Feb 2017 12:25:10 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 1ED00394004E
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 12:25:08 +0530 (IST)
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1E6t84j43909184
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 12:25:08 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1E6t62X022526
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 12:25:07 +0530
Subject: Re: [PATCH V2 0/3] Define coherent device memory node
References: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
 <b67ad176-80b6-66ca-3b65-f5b8ae07e92f@suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 14 Feb 2017 12:25:01 +0530
MIME-Version: 1.0
In-Reply-To: <b67ad176-80b6-66ca-3b65-f5b8ae07e92f@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <26225e15-4403-c4cd-513c-f80ad244c897@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/13/2017 09:04 PM, Vlastimil Babka wrote:
> On 02/10/2017 11:06 AM, Anshuman Khandual wrote:
>> 	This three patches define CDM node with HugeTLB & Buddy allocation
>> isolation. Please refer to the last RFC posting mentioned here for details.
>> The series has been split for easier review process. The next part of the
>> work like VM flags, auto NUMA and KSM interactions with tagged VMAs will
>> follow later.
> 
> Hi,
> 
> I'm not sure if the splitting to smaller series and focusing on partial
> implementations is helpful at this point, until there's some consensus
> about the whole approach from a big picture perspective.

I have been trying for that through RFCs on CDM but there were not
enough needed feedback from the larger MM community. Hence decided
to split up the series and ask for smaller chunks of code to be
reviewed, debated. Thought this will be a better approach. These
three patches are complete in themselves from functionality point of
view. VMA flags, auto NUMA, KSM are additional feature improvement on
this core set of patches.

RFC V2: https://lkml.org/lkml/2017/1/29/198  (zonelist and cpuset)
RFC V1: https://lkml.org/lkml/2016/10/24/19  (zonelist method)
RFC v2: https://lkml.org/lkml/2016/11/22/339 (cpuset method)

> 
> Note that it's also confusing that v1 of this partial patchset mentioned
> some alternative implementations, but only as git branches, and the
> discussion about their differences is linked elsewhere. That further
> makes meaningful review harder IMHO.

I had posted two alternate approaches except the GFP flag buddy method
in my last RFC. There were not much of discussion on them except some
generic top cpuset characteristics. The current posted nodemask based
isolation method is the minimalist, less intrusive and very less amount
of code change without affecting much of common MM code IMHO. But yes,
if required I can go ahead and post all other alternate methods on this
thread if looking into them helps in better comparison and review.

> 
> Going back to the bigger picture, I've read the comments on previous
> postings and I think Jerome makes many good points in this subthread [1]
> against the idea of representing the device memory as generic memory
> nodes and expecting userspace to mbind() to them. So if I make a program
> that uses mbind() to back some mmapped area with memory of "devices like
> accelerators, GPU cards, network cards, FPGA cards, PLD cards etc which
> might contain on board memory", then it will get such memory... and then
> what? How will it benefit from it? I will also need to tell some driver
> to make the device do some operations with this memory, right? And that
> most likely won't be a generic operation. In that case I can also ask
> the driver to give me that memory in the first place, and it can apply
> whatever policies are best for the device in question? And it's also the
> driver that can detect if the device memory is being wasted by a process
> that isn't currently performing the interesting operations, while
> another process that does them had to fallback its allocations to system
> memory and thus runs slower. I expect the NUMA balancing can't catch
> that for device memory (and you also disable it anyway?) So I don't
> really see how a generic solution would work, without having a full
> concrete example, and thus it's really hard to say that this approach is
> the right way to go and should be merged.

Okay, let me attempt to explain this.

* User space using mbind() to get CDM memory is an additional benefit
  we get by making the CDM plug in as a node and be part of the buddy
  allocator. But the over all idea from the user space point of view
  is that the application can allocate any generic buffer and try to
  use the buffer either from the CPU side or from the device without
  knowing about where the buffer is really mapped physically. That
  gives a seamless and transparent view to the user space where CPU
  compute and possible device based compute can work together. This
  is not possible through a driver allocated buffer.

* The placement of the memory on the buffer can happen on system memory
  when the CPU faults while accessing it. But a driver can manage the
  migration between system RAM and CDM memory once the buffer is being
  used from CPU and the device interchangeably. As you have mentioned
  driver will have more information about where which part of the buffer
  should be placed at any point of time and it can make it happen with
  migration. So both allocation and placement are decided by the driver
  during runtime. CDM provides the framework for this can kind device
  assisted compute and driver managed memory placements.

* If any application is not using CDM memory for along time placed on
  its buffer and another application is forced to fallback on system
  RAM when it really wanted is CDM, the driver can detect these kind
  of situations through memory access patters on the device HW and
  take necessary migration decisions.

I hope this explains the rationale of the framework.
 
> 
> The only examples I've noticed that don't require any special operations
> to benefit from placement in the "device memory", were fast memories
> like MCDRAM, which differentiate by performance of generic CPU
> operations, so it's not really a "device memory" by your terminology.
> And I would expect policing access to such performance differentiated
> memory is already possible with e.g. cpusets?

Not sure whether I understand this correctly but if any memory can be
treated like a normal memory and there is no off CPU device compute
kind of context which can access the memory coherently, then CDM will
not be an appropriate framework for it to use.

> 
> Thanks,
> Vlastimil
> 
> [1] https://lkml.kernel.org/r/20161025153256.GB6131@gmail.com
> 
>> https://lkml.org/lkml/2017/1/29/198
>>
>> Changes in V2:
>>
>> * Removed redundant nodemask_has_cdm() check from zonelist iterator
>> * Dropped the nodemask_had_cdm() function itself
>> * Added node_set/clear_state_cdm() functions and removed bunch of #ifdefs
>> * Moved CDM helper functions into nodemask.h from node.h header file
>> * Fixed the build failure by additional CONFIG_NEED_MULTIPLE_NODES check
>>
>> Previous V1: (https://lkml.org/lkml/2017/2/8/329)
>>
>> Anshuman Khandual (3):
>>   mm: Define coherent device memory (CDM) node
>>   mm: Enable HugeTLB allocation isolation for CDM nodes
>>   mm: Enable Buddy allocation isolation for CDM nodes
>>
>>  Documentation/ABI/stable/sysfs-devices-node |  7 ++++
>>  arch/powerpc/Kconfig                        |  1 +
>>  arch/powerpc/mm/numa.c                      |  7 ++++
>>  drivers/base/node.c                         |  6 +++
>>  include/linux/nodemask.h                    | 58 ++++++++++++++++++++++++++++-
>>  mm/Kconfig                                  |  4 ++
>>  mm/hugetlb.c                                | 25 ++++++++-----
>>  mm/memory_hotplug.c                         |  3 ++
>>  mm/page_alloc.c                             | 24 +++++++++++-
>>  9 files changed, 123 insertions(+), 12 deletions(-)
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
