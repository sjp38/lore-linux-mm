Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A03F46B0022
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 08:45:43 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a125so622463qkd.4
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 05:45:43 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id k2si2471336qth.409.2018.04.06.05.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 05:45:42 -0700 (PDT)
Date: Fri, 6 Apr 2018 08:45:35 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity
 checking
Message-ID: <20180406124535.k3qyxjfrlo55d5if@xakep.localdomain>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
 <20180131210300.22963-2-pasha.tatashin@oracle.com>
 <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
 <CAGM2reaPK=ZcLBOnmBiC2-u86DZC6ukOhL1xxZofB2OTW3ozoA@mail.gmail.com>
 <20180314005350.6xdda2uqzuy4n3o6@sasha-lappy>
 <20180315190430.o3vs7uxlafzdwgzd@xakep.localdomain>
 <20180315204312.n7p4zzrftgg6m7zw@sasha-lappy>
 <20180404021746.m77czxidkaumkses@xakep.localdomain>
 <20180405134940.2yzx4p7hjed7lfdk@xakep.localdomain>
 <20180405192256.GQ7561@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405192256.GQ7561@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "bharata@linux.vnet.ibm.com" <bharata@linux.vnet.ibm.com>

On 18-04-05 19:22:58, Sasha Levin wrote:
> On Thu, Apr 05, 2018 at 09:49:40AM -0400, Pavel Tatashin wrote:
> >> Hi Sasha,
> >>
> >> I have registered on Azure's portal, and created a VM with 4 CPUs and 16G
> >> of RAM. However, I still was not able to reproduce the boot bug you found.
> >
> >I have also tried to reproduce this issue on Windows 10 + Hyper-V, still
> >unsuccessful.
> 
> I'm not sure why you can't reproduce it. I built a 4.16 kernel + your 6
> patches on top, and booting on a D64s_v3 instance gives me this:

Hi Sasha,

Thank you for running it again, the new trace is cleaner, as we do not get
nested panics within dump_page.

Perhaps a NUMA is required to reproduce this issue. I have tried,
unsuccessfully, on D4S_V3. This is the largest VM allowed with free trial,
as 4 CPU is the limit. D64S_V3 is with 64 CPUs and over $2K a month! :)

Let me study your trace, perhaps I will able to figure out the issue
without reproducing it.

Thank you,
Pasha
