Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 845336B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 03:31:36 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l68so24363142wml.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 00:31:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h84si24405780wmf.124.2016.03.01.00.31.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 00:31:35 -0800 (PST)
Subject: Re: [RFC PATCH] mm: CONFIG_NR_ZONES_EXTENDED
References: <20160128061914.32541.97351.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160201214213.2bdf9b4e.akpm@linux-foundation.org>
 <56D43AAB.2010802@suse.cz>
 <CAPcyv4i587ow4yEFN+81rd=_kVL3YV1daU7cDM4V4YCAhDMRVA@mail.gmail.com>
 <56D4DCFE.9040806@suse.cz>
 <CAPcyv4j1JbpuoiurRe7hbnBbxthK3wtuoQXzwQ7rAcc+2MYV9A@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D55359.3080809@suse.cz>
Date: Tue, 1 Mar 2016 09:31:21 +0100
MIME-Version: 1.0
In-Reply-To: <CAPcyv4j1JbpuoiurRe7hbnBbxthK3wtuoQXzwQ7rAcc+2MYV9A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Mark <markk@clara.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On 03/01/2016 03:06 AM, Dan Williams wrote:
> On Mon, Feb 29, 2016 at 4:06 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> On 29.2.2016 18:55, Dan Williams wrote:
>>> On Mon, Feb 29, 2016 at 4:33 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>> On 02/02/2016 06:42 AM, Andrew Morton wrote:
>>>
>>> In this case it's already part of the equation because:
>>>
>>> config ZONE_DEVICE
>>>        depends on MEMORY_HOTPLUG
>>>        depends on MEMORY_HOTREMOVE
>>>
>>> ...and those in turn depend on SPARSEMEM.
>>
>> Fine, but then SPARSEMEM_VMEMMAP should be still an available subvariant of
>> SPARSEMEM with SECTION_WIDTH=0.
>
> It should be, but not for the ZONE_DEVICE case.  ZONE_DEVICE depends
> on x86_64 which means ZONE_DEVICE also implies SPARSEMEM_VMEMMAP
> since:
>
> config ARCH_SPARSEMEM_ENABLE
>         def_bool y
>         depends on X86_64 || NUMA || X86_32 || X86_32_NON_STANDARD
>         select SPARSEMEM_STATIC if X86_32
>         select SPARSEMEM_VMEMMAP_ENABLE if X86_64
>
> Now, if a future patch wants to reclaim page flags space for other
> usages outside of ZONE_DEVICE it can do the work to handle the
> SPARSEMEM_VMEMMAP=n case.  I don't see a reason to fold that
> distinction into the current patch given the current constraints.

OK so that IUUC shows that x86_64 should be always fine without decreasing the 
range for NODES_SHIFT? That's basically my point - since there's a configuration 
where things don't fit (32bit?), the patch broadly decreases range for 
NODES_SHIFT for everyone, right?

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
