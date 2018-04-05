Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 511C76B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 09:49:47 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id h5so18386141ual.18
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 06:49:47 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x62si3022313vkf.129.2018.04.05.06.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 06:49:46 -0700 (PDT)
Date: Thu, 5 Apr 2018 09:49:40 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity
 checking
Message-ID: <20180405134940.2yzx4p7hjed7lfdk@xakep.localdomain>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
 <20180131210300.22963-2-pasha.tatashin@oracle.com>
 <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
 <CAGM2reaPK=ZcLBOnmBiC2-u86DZC6ukOhL1xxZofB2OTW3ozoA@mail.gmail.com>
 <20180314005350.6xdda2uqzuy4n3o6@sasha-lappy>
 <20180315190430.o3vs7uxlafzdwgzd@xakep.localdomain>
 <20180315204312.n7p4zzrftgg6m7zw@sasha-lappy>
 <20180404021746.m77czxidkaumkses@xakep.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404021746.m77czxidkaumkses@xakep.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "bharata@linux.vnet.ibm.com" <bharata@linux.vnet.ibm.com>

> Hi Sasha,
> 
> I have registered on Azure's portal, and created a VM with 4 CPUs and 16G
> of RAM. However, I still was not able to reproduce the boot bug you found.

I have also tried to reproduce this issue on Windows 10 + Hyper-V, still
unsuccessful.

> 
> Could you please try an updated patch that I sent out today, the panic
> message should improve:
> 
> https://lkml.org/lkml/2018/4/3/583
> 
> Thank you,
> Pasha
> 
