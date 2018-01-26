Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C29916B0003
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 13:47:04 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 64so754772pgc.17
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 10:47:04 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m82si6703866pfi.343.2018.01.26.10.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jan 2018 10:47:03 -0800 (PST)
Date: Fri, 26 Jan 2018 11:47:01 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [LSF/MM TOPIC] CAPI/CCIX cache coherent device memory (NUMA too
 ?)
Message-ID: <20180126184701.GA14734@linux.intel.com>
References: <20180116210321.GB8801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116210321.GB8801@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Jonathan Masters <jcm@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Jan 16, 2018 at 04:03:21PM -0500, Jerome Glisse wrote:
> CAPI (on IBM Power8 and 9) and CCIX are two new standard that
> build on top of existing interconnect (like PCIE) and add the
> possibility for cache coherent access both way (from CPU to
> device memory and from device to main memory). This extend
> what we are use to with PCIE (where only device to main memory
> can be cache coherent but not CPU to device memory).
> 
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
> 
> We can start by looking at how CAPI and CCIX plan to expose this
> to the kernel and try to list some of the type of devices we
> expect to see. Discussion can then happen on how to represent this
> internaly to the kernel and how to expose this to userspace.
> 
> Note this might also trigger discussion on a NUMA like model or
> on extending/replacing it by something more generic.
> 
> 
> Peoples (alphabetical order on first name) sorry if i missed
> anyone:
>     "Anshuman Khandual" <khandual@linux.vnet.ibm.com>
>     "Balbir Singh" <bsingharora@gmail.com>
>     "Dan Williams" <dan.j.williams@intel.com>
>     "John Hubbard" <jhubbard@nvidia.com>
>     "Jonathan Masters" <jcm@redhat.com>
>     "Ross Zwisler" <ross.zwisler@linux.intel.com>

I'd love to be part of this discussion, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
