Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8706B03A5
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 08:10:34 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so15881717wmi.6
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 05:10:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r123si16402434wmd.141.2017.02.21.05.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 05:10:31 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LD3rxV038093
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 08:10:29 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28rj2rb0pg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 08:10:29 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 21 Feb 2017 23:10:26 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 237673578056
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:10:23 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1LDAF0r15532062
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:10:23 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1LD9oaU025202
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:09:50 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170217133237.v6rqpsoiolegbjye@suse.de>
Date: Tue, 21 Feb 2017 18:39:17 +0530
MIME-Version: 1.0
In-Reply-To: <20170217133237.v6rqpsoiolegbjye@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Message-Id: <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/17/2017 07:02 PM, Mel Gorman wrote:
> On Fri, Feb 17, 2017 at 05:11:57PM +0530, Anshuman Khandual wrote:
>> On 02/15/2017 11:50 PM, Mel Gorman wrote:
>>> On Wed, Feb 15, 2017 at 05:37:22PM +0530, Anshuman Khandual wrote:
>>>> 	This four patches define CDM node with HugeTLB & Buddy allocation
>>>> isolation. Please refer to the last RFC posting mentioned here for more
>>>
>>> Always include the background with the changelog itself. Do not assume that
>>> people are willing to trawl through a load of past postings to assemble
>>> the picture. I'm only taking a brief look because of the page allocator
>>> impact but it does not appear that previous feedback was addressed.
>>
>> Sure, I made a mistake. Will include the complete background from my
>> previous RFCs in the next version which will show the entire context
>> of this patch series. I have addressed the previous feedback regarding
>> cpuset enabled allocation leaks into CDM memory as pointed out by
>> Vlastimil Babka on the last version. Did I miss anything else inside
>> the Buddy allocator apart from that ?
>>
> 
> The cpuset fix is crude and uncondtionally passes around a mask to
> special case CDM requirements which should be controlled by cpusets or
> policies if CDM is to be treated as if it's normal memory. Special
> casing like this is fragile and it'll be difficult for modifications to
> the allocator to be made with any degree of certainity that CDM is not
> impacted. I strongly suspect it would collide with the cpuset rework
> that Vlastimil is working on to avoid races between allocation and
> cpuset modification.

I understand your point. Cpuset can should be improved to accommodate
CDM nodes through policy constructs not through special casing. I will
look into it again and work with Vlastimil to see if the new rework can
accommodate these.

> 
>>>
>>> In itself, the series does very little and as Vlastimil already pointed
>>> out, it's not a good idea to try merge piecemeal when people could not
>>> agree on the big picture (I didn't dig into it).
>>
>> With the proposed kernel changes and a associated driver its complete to
>> drive a user space based CPU/Device hybrid compute interchangeably on a
>> mmap() allocated memory buffer transparently and effectively.
> 
> How is the device informed at that data is available for processing?

It will through a call to the driver from user space which can take
the required buffer address as an argument.

> What prevents and application modifying the data on the device while it's
> being processed?

Nothing in software. The application should take care of that but access
from both sides are coherent. It should wait for the device till it
finishes the compute it had asked for earlier to prevent override and
eventual corruption.

> Why can this not be expressed with cpusets and memory policies
> controlled by a combination of administrative steps for a privileged
> application and an application that is CDM aware?

Hmm, that can be done but having an in kernel infrastructure has the
following benefits.

* Administrator does not have to listen to node add notifications
  and keep the isolation/allowed cpusets upto date all the time.
  This can be a significant overhead on the admin/userspace which
  have a number of separate device memory nodes.

* With cpuset solution, tasks which are part of CDM allowed cpuset
  can have all it's VMAs allocate from CDM memory which may not be
  something the user want. For example user may not want to have
  the text segments, libraries allocate from CDM. To achieve this
  the user will have to explicitly block allocation access from CDM
  through mbind(MPOL_BIND) memory policy setups. This negative setup
  is a big overhead. But with in kernel CDM framework, isolation is
  enabled by default. For CDM allocations the application just has
  to setup memory policy with CDM node in the allowed nodemask.

Even with cpuset solution, applications still need to know which nodes
are CDM on the system at given point of time. So we will have to store
it in a nodemask and export them on sysfs some how.

> 
>> I had also
>> mentioned these points on the last posting in response to a comment from
>> Vlastimil.
>>
>> From this response (https://lkml.org/lkml/2017/2/14/50).
>>
>> * User space using mbind() to get CDM memory is an additional benefit
>>   we get by making the CDM plug in as a node and be part of the buddy
>>   allocator. But the over all idea from the user space point of view
>>   is that the application can allocate any generic buffer and try to
>>   use the buffer either from the CPU side or from the device without
>>   knowing about where the buffer is really mapped physically. That
>>   gives a seamless and transparent view to the user space where CPU
>>   compute and possible device based compute can work together. This
>>   is not possible through a driver allocated buffer.
>>
> 
> Which can also be done with cpusets that prevents use of CDM memory and
> place all non-CDM processes into that cpuset with a separate cpuset for
> CDM-aware applications that allow access to CDM memory.

Right, but with additional overheads as explained above.

> 
>> * The placement of the memory on the buffer can happen on system memory
>>   when the CPU faults while accessing it. But a driver can manage the
>>   migration between system RAM and CDM memory once the buffer is being
>>   used from CPU and the device interchangeably.
> 
> While I'm not familiar with the details because I'm not generally involved
> in hardware enablement, why was HMM not suitable? I know HMM had it's own
> problems with merging but as it also managed migrations between RAM and
> device memory, how did it not meet your requirements? If there were parts
> of HMM missing, why was that not finished?


These are the reasons which prohibit the use of HMM for coherent
addressable device memory purpose.

(1) IIUC HMM currently supports only a subset of anon mapping in the
user space. It does not support shared anon mapping or any sort of file
mapping for that matter. We need support for all mapping in the user space
for the CPU/device compute to be effective and transparent. As HMM depends
on ZONE DEVICE for device memory representation, there are some unique
challenges in making it work for file mapping (and page cache) during
migrations between system RAM and device memory.

(2) ZONE_DEVICE has been modified to support un-addressable memory apart
from addressable persistent memory which is not movable. It still would
have to support coherent device memory which will be movable.

(3) Application cannot directly allocate into device memory from user
space using existing memory related system calls like mmap() and mbind()
as the device memory hides away in ZONE_DEVICE.

Apart from that, CDM framework provides a different approach to device
memory representation which does not require special device memory kind
of handling and associated call backs as implemented by HMM. It provides
NUMA node based visibility to the user space which can be extended to
support new features.

>
> I know HMM had a history of problems getting merged but part of that was a
> chicken and egg problem where it was a lot of infrastructure to maintain
> with no in-kernel users. If CDM is a potential user then CDM could be

CDM is not a user there, HMM needs to change (with above challenges) to
accommodate coherent device memory which it does not support at this
moment.

> built on top and ask for a merge of both the core infrastructure required
> and the drivers at the same time.

I am afraid the drivers would be HW vendor specific.

> 
> It's not an easy path but the difficulties there do not justify special
> casing CDM in the core allocator.

Hmm. Even if HMM supports all sorts of mappings in user space and related
migrations, we still will not have direct allocations from user space with
mmap() and mbind() system calls.

> 
> 
>>   As you have mentioned
>>   driver will have more information about where which part of the buffer
>>   should be placed at any point of time and it can make it happen with
>>   migration. So both allocation and placement are decided by the driver
>>   during runtime. CDM provides the framework for this can kind device
>>   assisted compute and driver managed memory placements.
>>
> 
> Which sounds like what HMM needed and the problems of co-ordinating whether
> data within a VMA is located on system RAM or device memory and what that
> means is not addressed by the series.

Did not get that. What is not addressed by this series ? How is the
requirements of HMM and CDM framework are different ?

> 
> Even if HMM is unsuitable, it should be clearly explained why

I just did explain in the previous paragraphs above.

> 
>> * If any application is not using CDM memory for along time placed on
>>   its buffer and another application is forced to fallback on system
>>   RAM when it really wanted is CDM, the driver can detect these kind
>>   of situations through memory access patterns on the device HW and
>>   take necessary migration decisions.
>>
>> I hope this explains the rationale of the framework. In fact these
>> four patches give logically complete CPU/Device operating framework.
>> Other parts of the bigger picture are VMA management, KSM, Auto NUMA
>> etc which are improvements on top of this basic framework.
>>
> 
> Automatic NUMA balancing is a particular oddity as that is about
> CPU->RAM locality and not RAM->device considerations.

Right. But when there are migrations happening between system RAM and
device memory. Auto NUMA with its CPU fault information can migrate
between system RAM nodes which might not be necessary and can lead to
conflict or overhead. Hence Auto NUMA needs to be switched off at times
for the VMAs of concern but its not addressed in the patch series. As
mentioned before, it will be in the follow up work as improvements on
this series.

> 
> But all that aside, it still does not explain why it's necessary to
> special case CDM in the allocator paths that can be controlled with
> existing mechanisms.

Okay

> 
>>>
>>> The only reason I'm commenting at all is to say that I am extremely opposed
>>> to the changes made to the page allocator paths that are specific 	
>>> CDM. It's been continual significant effort to keep the cost there down
>>> and this is a mess of special cases for CDM. The changes to hugetlb to
>>> identify "memory that is not really memory" with special casing is also
>>> quite horrible.
>>
>> We have already removed the O (n^2) search during zonelist iteration as
>> pointed out by Vlastimil and the current overhead is linear for the CDM
>> special case. We do similar checks for the cpuset function as well. Then
>> how is this horrible ?
> 
> Because there are existing mechanisms for avoiding nodes that are not
> device specific.

So the changes are not horrible but they might be called redundant.

> 
>> On HugeTLB, we isolate CDM based on a resultant
>> (MEMORY - CDM) node_states[] element which identifies system memory
>> instead of all of the accessible memory and keep the HugeTLB limited to
>> that nodemask. But if you feel there is any other better approach, we
>> can definitely try out.
>>
> 
> cpusets with non-CDM application in a cpuset that does not include CDM
> nodes.

Okay, if cpuset turns out to be a viable option for CDM implementation.

> 
>>> It's also unclear if this is even usable by an application in userspace
>>> at this point in time. If it is and the special casing is needed then the
>>
>> Yeah with the current CDM approach its usable from user space as
>> explained before.
>>
> 
> Minus the parts where the application notifies the driver to do some work
> or mediate between what is accessing what memory and when.

As mentioned before application invokes the driver to start a device compute
on a designated buffer, waits for the completion till driver returns the call
back to the application and then application accesses the buffer from CPU. Yes
application needs to work with the driver to guarantee buffer data integrity
and prevent corruption.

> 
>>> regions should be isolated from early mem allocations in the arch layer
>>> that is CDM aware, initialised late, and then setup userspace to isolate
>>> all but privileged applications from the CDM nodes. Do not litter the core
>>> with is_cdm_whatever checks.
>>
>> I guess your are referring to allocating the entire CDM memory node with
>> memblock_reserve() and then arch managing the memory when user space
>> wants to use it through some sort of mmap, vm_ops methods. That defeats
>> the whole purpose of integrating CDM memory with core VM. I am afraid it
>> will also make migration between CDM memory and system memory difficult
>> which is essential in making the whole hybrid compute operation
>> transparent from  the user space.
>>
> 
> The memblock is to only avoid bootmem allocations from that area. It can
> be managed in the arch layer to first pass in all the system ram,
> teardown the bootmem allocator, setup the nodelists, set system
> nodemask, init CDM, init the allocator for that, and then optionally add
> it to the system CDM for userspace to do the isolation or provide.
> 
> For that matter, the driver could do the discovery and then fake a
> memory hot-add.

Not sure I got this correctly. Could you please explain more.

> 
> It would be tough to do this but it would confine the logic to the arch
> and driver that cares instead of special casing the allocators.

I did not get this part, could you please give some more details.

> 
>>> At best this is incomplete because it does not look as if it could be used
>>> by anything properly and the fast path alterations are horrible even if
>>> it could be used. As it is, it should not be merged in my opinion.
>>
>> I have mentioned in detail above how this much of code change enables
>> us to use the CDM in a transparent way from the user space. Please do
>> let me know if it still does not make sense, will try again.
>>
>> On the fast path changes issue, I can really understand your concern
>> from the performance point of viewi
> 
> And a maintenance overhead because changing any part where CDM is special
> cased will be impossible for many to test and verify.

Okay.

> 
>> as its achieved over a long time.
>> It would be great if you can suggest on how to improve from here.
>>
> 
> I do not have the bandwidth to get involved in how hardware enablement
> for this feature should be done on power. The objection is that however
> it is handled should not need to add special casing to the allocator
> which already has mechanisms for limiting what memory is used.
> 

Okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
