Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D06D6B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 16:43:18 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id h61-v6so3836795pld.3
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:43:18 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0133.outbound.protection.outlook.com. [104.47.37.133])
        by mx.google.com with ESMTPS id az5-v6si4579496plb.617.2018.03.15.13.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 13:43:16 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity
 checking
Date: Thu, 15 Mar 2018 20:43:14 +0000
Message-ID: <20180315204312.n7p4zzrftgg6m7zw@sasha-lappy>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
 <20180131210300.22963-2-pasha.tatashin@oracle.com>
 <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
 <CAGM2reaPK=ZcLBOnmBiC2-u86DZC6ukOhL1xxZofB2OTW3ozoA@mail.gmail.com>
 <20180314005350.6xdda2uqzuy4n3o6@sasha-lappy>
 <20180315190430.o3vs7uxlafzdwgzd@xakep.localdomain>
In-Reply-To: <20180315190430.o3vs7uxlafzdwgzd@xakep.localdomain>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <698089C6C27CF943BDBEFE8F28446663@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "bharata@linux.vnet.ibm.com" <bharata@linux.vnet.ibm.com>

On Thu, Mar 15, 2018 at 03:04:30PM -0400, Pavel Tatashin wrote:
>>
>> Attached the config. It just happens on boot.
>
>Hi Sasha,
>
>I have tried unsuccessfully to reproduce the bug in qemu with 20G RAM,
>and 8 CPUs.
>
>Patch "mm: uninitialized struct page poisoning sanity" should be improved
>to make dump_page() to detect poisoned struct page, and simply print hex
>in such case. I will send an updated patch later.
>
>How do you run this on Microsoft hypervisor? Do I need Windows 10 for
>that?

Booting a Linux VM on Azure would be the easiest, and free too :)

>BTW, I am going to be on vacation for the next two week (going to Israel),
>so I may not be able to response quickly.

Have fun!

We may need to hold off on getting this patch merged for the time being.

--=20

Thanks,
Sasha=
