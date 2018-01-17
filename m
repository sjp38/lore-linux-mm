Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C745280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:30:32 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id z73so9923538oia.16
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:30:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r131si1352186oih.19.2018.01.16.18.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 18:30:30 -0800 (PST)
Date: Tue, 16 Jan 2018 21:30:24 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] CAPI/CCIX cache coherent device memory (NUMA too
 ?)
Message-ID: <20180117023024.GB3492@redhat.com>
References: <20180116210321.GB8801@redhat.com>
 <CAF7GXvpsAPhHWFV3g9LdzKg6Fe=Csp+kecG+HznoaT0Hiu9HCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAF7GXvpsAPhHWFV3g9LdzKg6Fe=Csp+kecG+HznoaT0Hiu9HCw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Jonathan Masters <jcm@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Jan 17, 2018 at 09:55:14AM +0800, Figo.zhang wrote:
> 2018-01-17 5:03 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:
> 
> > CAPI (on IBM Power8 and 9) and CCIX are two new standard that
> > build on top of existing interconnect (like PCIE) and add the
> > possibility for cache coherent access both way (from CPU to
> > device memory and from device to main memory). This extend
> > what we are use to with PCIE (where only device to main memory
> > can be cache coherent but not CPU to device memory).
> >
> 
> the UPI bus also support cache coherency for Intel platform, right?

AFAIK the UPI only apply between processors and is not expose to devices
except integrated Intel devices (like Intel GPU or FPGA) thus it is less
generic/open than CAPI/CCIX.

> it seem the specification of CCIX/CAPI protocol is not public, we cannot
> know the details about them, your topic will cover the details?

I can only cover what will be public at the time of summit but for
the sake of discussion the important characteristic is the cache
coherency aspect. Discussing how it is implemented, cache line
protocol and all the gory details of protocol is of little interest
from kernel point of view.


> > How is this memory gonna be expose to the kernel and how the
> > kernel gonna expose this to user space is the topic i want to
> > discuss. I believe this is highly device specific for instance
> > for GPU you want the device memory allocation and usage to be
> > under the control of the GPU device driver. Maybe other type
> > of device want different strategy.
> >
> i see it lack of some simple example for how to use the HMM, because
> GPU driver is more complicate for linux driver developer  except the
> ATI/NVIDIA developers.

HMM require a device with an MMU and capable of pausing workload that
do pagefault. Only devices complex enough i know of are GPU, Infiniband
and FPGA. HMM from feedback i had so far is that most people working on
any such device driver understand HMM. I am always happy to answer any
specific questions on the API and how it is intended to be use by device
driver (and improve kernel documentation in the process).

How HMM functionality is then expose to userspace by the device driver
is under the control of each individual device driver.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
