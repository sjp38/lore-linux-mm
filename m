Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF496B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 22:17:55 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id a5so9699699uak.17
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 19:17:55 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y184si1720192vka.35.2018.04.03.19.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 19:17:53 -0700 (PDT)
Date: Tue, 3 Apr 2018 22:17:46 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity
 checking
Message-ID: <20180404021746.m77czxidkaumkses@xakep.localdomain>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
 <20180131210300.22963-2-pasha.tatashin@oracle.com>
 <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
 <CAGM2reaPK=ZcLBOnmBiC2-u86DZC6ukOhL1xxZofB2OTW3ozoA@mail.gmail.com>
 <20180314005350.6xdda2uqzuy4n3o6@sasha-lappy>
 <20180315190430.o3vs7uxlafzdwgzd@xakep.localdomain>
 <20180315204312.n7p4zzrftgg6m7zw@sasha-lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180315204312.n7p4zzrftgg6m7zw@sasha-lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "bharata@linux.vnet.ibm.com" <bharata@linux.vnet.ibm.com>

On 18-03-15 20:43:14, Sasha Levin wrote:
> On Thu, Mar 15, 2018 at 03:04:30PM -0400, Pavel Tatashin wrote:
> >>
> >> Attached the config. It just happens on boot.
> >
> >Hi Sasha,
> >
> >I have tried unsuccessfully to reproduce the bug in qemu with 20G RAM,
> >and 8 CPUs.
> >
> >Patch "mm: uninitialized struct page poisoning sanity" should be improved
> >to make dump_page() to detect poisoned struct page, and simply print hex
> >in such case. I will send an updated patch later.
> >
> >How do you run this on Microsoft hypervisor? Do I need Windows 10 for
> >that?
> 
> Booting a Linux VM on Azure would be the easiest, and free too :)

Hi Sasha,

I have registered on Azure's portal, and created a VM with 4 CPUs and 16G
of RAM. However, I still was not able to reproduce the boot bug you found.

Could you please try an updated patch that I sent out today, the panic
message should improve:

https://lkml.org/lkml/2018/4/3/583

Thank you,
Pasha
