Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B06F86B0009
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 19:06:23 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l68so11619277wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 16:06:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id km9si34485748wjb.149.2016.02.29.16.06.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Feb 2016 16:06:22 -0800 (PST)
Subject: Re: [RFC PATCH] mm: CONFIG_NR_ZONES_EXTENDED
References: <20160128061914.32541.97351.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160201214213.2bdf9b4e.akpm@linux-foundation.org>
 <56D43AAB.2010802@suse.cz>
 <CAPcyv4i587ow4yEFN+81rd=_kVL3YV1daU7cDM4V4YCAhDMRVA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D4DCFE.9040806@suse.cz>
Date: Tue, 1 Mar 2016 01:06:22 +0100
MIME-Version: 1.0
In-Reply-To: <CAPcyv4i587ow4yEFN+81rd=_kVL3YV1daU7cDM4V4YCAhDMRVA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Mark <markk@clara.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On 29.2.2016 18:55, Dan Williams wrote:
> On Mon, Feb 29, 2016 at 4:33 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> On 02/02/2016 06:42 AM, Andrew Morton wrote:
>>> So if you want ZONE_DMA, you're limited to 512 NUMA nodes?
>>>
>>> That seems reasonable.
>>
>>
>> Sorry for the late reply, but it seems that with !SPARSEMEM, or with
>> SPARSEMEM_VMEMMAP, reducing NUMA nodes isn't even necessary, because
>> SECTIONS_WIDTH is zero (see the diagrams in linux/page-flags-layout.h). In
>> my brief tests with 4.4 based kernel with SPARSEMEM_VMEMMAP it seems that
>> with 1024 NUMA nodes and 8192 CPU's, there's still 7 bits left (i.e. 6 with
>> CONFIG_NR_ZONES_EXTENDED).
>>
>> With the danger of becoming even more complex, could the limit also depend
>> on CONFIG_SPARSEMEM/VMEMMAP to reflect that somehow?
> 
> In this case it's already part of the equation because:
> 
> config ZONE_DEVICE
>        depends on MEMORY_HOTPLUG
>        depends on MEMORY_HOTREMOVE
> 
> ...and those in turn depend on SPARSEMEM.

Fine, but then SPARSEMEM_VMEMMAP should be still an available subvariant of
SPARSEMEM with SECTION_WIDTH=0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
