Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2725E6B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 15:04:38 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id y64so7982740ywd.13
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:04:38 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g12-v6si1100079ybf.620.2018.03.15.12.04.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 12:04:37 -0700 (PDT)
Date: Thu, 15 Mar 2018 15:04:30 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity
 checking
Message-ID: <20180315190430.o3vs7uxlafzdwgzd@xakep.localdomain>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
 <20180131210300.22963-2-pasha.tatashin@oracle.com>
 <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
 <CAGM2reaPK=ZcLBOnmBiC2-u86DZC6ukOhL1xxZofB2OTW3ozoA@mail.gmail.com>
 <20180314005350.6xdda2uqzuy4n3o6@sasha-lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180314005350.6xdda2uqzuy4n3o6@sasha-lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "bharata@linux.vnet.ibm.com" <bharata@linux.vnet.ibm.com>

> 
> Attached the config. It just happens on boot.

Hi Sasha,

I have tried unsuccessfully to reproduce the bug in qemu with 20G RAM,
and 8 CPUs.

Patch "mm: uninitialized struct page poisoning sanity" should be improved
to make dump_page() to detect poisoned struct page, and simply print hex
in such case. I will send an updated patch later.

How do you run this on Microsoft hypervisor? Do I need Windows 10 for
that?

BTW, I am going to be on vacation for the next two week (going to Israel),
so I may not be able to response quickly.

Thank you,
Pasha
