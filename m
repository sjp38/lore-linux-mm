Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FCAE6B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 04:30:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b25-v6so3009711eds.17
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 01:30:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q24-v6si838449edg.363.2018.08.10.01.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 01:30:55 -0700 (PDT)
Subject: Re: [PATCH v3] resource: Merge resources on a node when hot-adding
 memory
References: <20180809025409.31552-1-rashmica.g@gmail.com>
 <20180809181224.0b7417e51215565dbda9f665@linux-foundation.org>
 <CAC6rBs=yYYZw-c02yp6rx-+TN2oUGgrp=uuLhZ=Kc_nnjmTRqA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <41eb4fc8-3b57-478b-05b4-88bed24ed66e@suse.cz>
Date: Fri, 10 Aug 2018 10:28:26 +0200
MIME-Version: 1.0
In-Reply-To: <CAC6rBs=yYYZw-c02yp6rx-+TN2oUGgrp=uuLhZ=Kc_nnjmTRqA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashmica Gupta <rashmica.g@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: toshi.kani@hpe.com, tglx@linutronix.de, bp@suse.de, brijesh.singh@amd.com, thomas.lendacky@amd.com, jglisse@redhat.com, gregkh@linuxfoundation.org, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, malat@debian.org, Bjorn Helgaas <bhelgaas@google.com>, osalvador@techadventures.net, yasu.isimatu@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

On 08/10/2018 08:55 AM, Rashmica Gupta wrote:
> On Fri, Aug 10, 2018 at 11:12 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>>
>> What is the end-user impact of this patch?
>>
> 
> Only architectures/setups that allow the user to remove and add memory of
> different sizes or different start addresses from the kernel at runtime will
> potentially encounter the resource fragmentation.
> 
> Trying to remove memory that overlaps iomem resources the first time
> gives us this warning: "Unable to release resource <%pa-%pa>".
> 
> Attempting a second time results in a kernel oops (on ppc at least).

An oops? I think that should be investigated and fixed, even if resource
merging prevents it. Do you have the details?

Thanks,
Vlastimil
