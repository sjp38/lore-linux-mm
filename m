Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 381D56B0286
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:03:30 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id e19so11018404otf.4
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:03:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w130si1107072oib.393.2018.01.16.13.03.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 13:03:29 -0800 (PST)
Date: Tue, 16 Jan 2018 16:03:21 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: [LSF/MM TOPIC] CAPI/CCIX cache coherent device memory (NUMA too ?)
Message-ID: <20180116210321.GB8801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Jonathan Masters <jcm@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

CAPI (on IBM Power8 and 9) and CCIX are two new standard that
build on top of existing interconnect (like PCIE) and add the
possibility for cache coherent access both way (from CPU to
device memory and from device to main memory). This extend
what we are use to with PCIE (where only device to main memory
can be cache coherent but not CPU to device memory).

How is this memory gonna be expose to the kernel and how the
kernel gonna expose this to user space is the topic i want to
discuss. I believe this is highly device specific for instance
for GPU you want the device memory allocation and usage to be
under the control of the GPU device driver. Maybe other type
of device want different strategy.

The HMAT patchset is partialy related to all this as it is about
exposing different type of memory available in a system for CPU
(HBM, main memory, ...) and some of their properties (bandwidth,
latency, ...).


We can start by looking at how CAPI and CCIX plan to expose this
to the kernel and try to list some of the type of devices we
expect to see. Discussion can then happen on how to represent this
internaly to the kernel and how to expose this to userspace.

Note this might also trigger discussion on a NUMA like model or
on extending/replacing it by something more generic.


Peoples (alphabetical order on first name) sorry if i missed
anyone:
    "Anshuman Khandual" <khandual@linux.vnet.ibm.com>
    "Balbir Singh" <bsingharora@gmail.com>
    "Dan Williams" <dan.j.williams@intel.com>
    "John Hubbard" <jhubbard@nvidia.com>
    "Jonathan Masters" <jcm@redhat.com>
    "Ross Zwisler" <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
