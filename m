Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id BAC996B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 11:43:43 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id e71so8860542vkd.4
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 08:43:43 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f187sor1600683vkg.97.2018.01.17.08.43.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 08:43:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <c02d666d-d985-990f-eeec-e3e677a1b046@huawei.com>
References: <20180116210321.GB8801@redhat.com> <c02d666d-d985-990f-eeec-e3e677a1b046@huawei.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 17 Jan 2018 22:13:41 +0530
Message-ID: <CAKTCnzmNT-ObnKpXGtkDV9id2cY9NbxS5XBAqtQBgPr6XAQUJA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] CAPI/CCIX cache coherent device memory (NUMA too ?)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liubo(OS Lab)" <liubo95@huawei.com>
Cc: Jerome Glisse <jglisse@redhat.com>, lsf-pc <lsf-pc@lists.linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Jonathan Masters <jcm@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Jan 17, 2018 at 7:02 AM, Liubo(OS Lab) <liubo95@huawei.com> wrote:
> On 2018/1/17 5:03, Jerome Glisse wrote:
>> CAPI (on IBM Power8 and 9) and CCIX are two new standard that
>> build on top of existing interconnect (like PCIE) and add the
>> possibility for cache coherent access both way (from CPU to
>> device memory and from device to main memory). This extend
>> what we are use to with PCIE (where only device to main memory
>> can be cache coherent but not CPU to device memory).
>>
>
> Yes, and more than CAPI/CCIX.
> E.g A SoC may connected with different types of memory through internal system-bus.

cool! any references, docs?

>
>> How is this memory gonna be expose to the kernel and how the
>> kernel gonna expose this to user space is the topic i want to
>> discuss. I believe this is highly device specific for instance
>> for GPU you want the device memory allocation and usage to be
>> under the control of the GPU device driver. Maybe other type
>> of device want different strategy.
>>
>> The HMAT patchset is partialy related to all this as it is about
>> exposing different type of memory available in a system for CPU
>> (HBM, main memory, ...) and some of their properties (bandwidth,
>> latency, ...).
>>
>
> Yes, and different type of memory doesn't mean device-memory or Nvdimm only(which are always think not as reliable as DDR).
>

OK, so something probably as reliable system memory, but with
different characteristics

>>
>> We can start by looking at how CAPI and CCIX plan to expose this
>> to the kernel and try to list some of the type of devices we
>> expect to see. Discussion can then happen on how to represent this
>> internaly to the kernel and how to expose this to userspace.
>>
>> Note this might also trigger discussion on a NUMA like model or
>> on extending/replacing it by something more generic.
>>
>
> Agree, for NUMA model the node distance is not enough when a system has different type of memory.
> Like the HMAT patches mentioned, different bandwidth ,latency, ...
>

Yes, definitely worth discussing. The last time I posted
N_COHERENT_MEMORY as a patchset to isolate memory, but that met with a
lot of opposition due to lack of a full use case and end to end
demonstration. I think we can work on a proposal that provides the
benefits of NUMA, but that might require us to revisit what algorithms
should be run on what nodes, relationship between nodes.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
