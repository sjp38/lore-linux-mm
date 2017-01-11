Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 731906B0033
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 23:26:16 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z128so331395467pfb.4
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 20:26:16 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id g15si4432427plj.35.2017.01.10.20.26.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 20:26:15 -0800 (PST)
Date: Tue, 10 Jan 2017 20:22:43 -0800
From: John Hubbard <jhubbard@nvidia.com>
Subject: [LSF/MM ATTEND] HMM, CDM and other infrastructure for device memory
 management
Message-ID: <alpine.LNX.2.20.1701101600280.38701@blueforge.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Jerome Glisse <jglisse@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Serguei Sagalovitch <serguei.sagalovitch@amd.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Michael Repasy <mrepasy@nvidia.com>

Hi,

I would like to attend this topic that Jerome has proposed. Studying the 
kernel is a deep personal interest in addition to my career focus, and it 
would be a rare privilege to work directly with some of you to converge 
on some nice, clean designs for the kernel and these "new" 
(page-fault-capable) devices that we have now. Here's what I can bring to 
the discussion:

a) An NVIDIA perspective on, and experience with, using the HMM patchset, 
versions 1-15, at the device driver level. In addition to working on the 
nvidia-uvm.ko driver (which handles CPU and GPU page faulting) since its 
inception, I've also helped develop and maintain various facets of our GPU 
device driver for Linux, for the last 9 years.

As a semi-relevant aside, our company is allocating engineering time, 
including mine, for long-term kernel projects such as this one. We want to 
participate in maintaining and improving the kernel. I find that highly 
encouraging and I hope others do, too. Times really are changing.

b) Some thoughts about the dividing line between core kernel and drivers. 
Our device drivers are starting to push the limits of what drivers should 
really do (we are heading perhaps too deeply into memory management), and 
of course I want to avoid going too far. For example, I've seen 
recent comments on linux-mm that drivers shouldn't even take mmap_sem, 
which is intriguing. We need to provide...something for that, though. 

c) Some thoughts about dealing with both HMM and ATS in the same driver 
(our devices have to support both--although, not at the same time).

--

For this discussion track, I'm especially interested in simultaneously 
considering:

1. HMM (Jerome's Heterogeneous Memory Management patchset): this solves a 
similar problem as ATS (Address Translation Services: unified CPU and
Device page tables), but without the need for specialized hardware. There 
is a bit of overlap between the HMM and ATS+NUMA patchsets, as has been 
discussed here before.

2. IBM's ATS+NUMA patchset.

3. Page-fault-capable devices in general.

thanks,
John Hubbard 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
