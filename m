Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96469280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 20:34:24 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n6so12946782pfg.19
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:34:24 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id y77si3078821pfj.328.2018.01.16.17.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 17:34:22 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] CAPI/CCIX cache coherent device memory (NUMA too
 ?)
References: <20180116210321.GB8801@redhat.com>
From: "Liubo(OS Lab)" <liubo95@huawei.com>
Message-ID: <c02d666d-d985-990f-eeec-e3e677a1b046@huawei.com>
Date: Wed, 17 Jan 2018 09:32:59 +0800
MIME-Version: 1.0
In-Reply-To: <20180116210321.GB8801@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Jonathan
 Masters <jcm@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 2018/1/17 5:03, Jerome Glisse wrote:
> CAPI (on IBM Power8 and 9) and CCIX are two new standard that
> build on top of existing interconnect (like PCIE) and add the
> possibility for cache coherent access both way (from CPU to
> device memory and from device to main memory). This extend
> what we are use to with PCIE (where only device to main memory
> can be cache coherent but not CPU to device memory).
> 

Yes, and more than CAPI/CCIX.
E.g A SoC may connected with different types of memory through internal system-bus.

> How is this memory gonna be expose to the kernel and how the
> kernel gonna expose this to user space is the topic i want to
> discuss. I believe this is highly device specific for instance
> for GPU you want the device memory allocation and usage to be
> under the control of the GPU device driver. Maybe other type
> of device want different strategy.
> 
> The HMAT patchset is partialy related to all this as it is about
> exposing different type of memory available in a system for CPU
> (HBM, main memory, ...) and some of their properties (bandwidth,
> latency, ...).
> 

Yes, and different type of memory doesn't mean device-memory or Nvdimm only(which are always think not as reliable as DDR).

> 
> We can start by looking at how CAPI and CCIX plan to expose this
> to the kernel and try to list some of the type of devices we
> expect to see. Discussion can then happen on how to represent this
> internaly to the kernel and how to expose this to userspace.
> 
> Note this might also trigger discussion on a NUMA like model or
> on extending/replacing it by something more generic.
> 

Agree, for NUMA model the node distance is not enough when a system has different type of memory.
Like the HMAT patches mentioned, different bandwidth ,latency, ...

> 
> Peoples (alphabetical order on first name) sorry if i missed
> anyone:
>     "Anshuman Khandual" <khandual@linux.vnet.ibm.com>
>     "Balbir Singh" <bsingharora@gmail.com>
>     "Dan Williams" <dan.j.williams@intel.com>
>     "John Hubbard" <jhubbard@nvidia.com>
>     "Jonathan Masters" <jcm@redhat.com>
>     "Ross Zwisler" <ross.zwisler@linux.intel.com>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
