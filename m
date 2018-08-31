Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 284076B5717
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 09:12:14 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d1-v6so13674593qth.21
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 06:12:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v17-v6si7179329qtq.288.2018.08.31.06.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 06:12:13 -0700 (PDT)
Subject: Re: [PATCH RFCv2 1/6] mm/memory_hotplug: make remove_memory() take
 the device_hotplug_lock
References: <20180821104418.12710-1-david@redhat.com>
 <20180821104418.12710-2-david@redhat.com>
 <46a0119b-da16-0203-a8c2-d127738517f4@microsoft.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <5b1f79cd-553b-4f9d-2690-8d7fb553278e@redhat.com>
Date: Fri, 31 Aug 2018 15:12:05 +0200
MIME-Version: 1.0
In-Reply-To: <46a0119b-da16-0203-a8c2-d127738517f4@microsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rashmica Gupta <rashmica.g@gmail.com>, Michael Neuling <mikey@neuling.org>, Balbir Singh <bsingharora@gmail.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>

On 30.08.2018 21:35, Pasha Tatashin wrote:
>> +
>> +void __ref remove_memory(int nid, u64 start, u64 size)
> 
> Remove __ref, otherwise looks good:

Indeed, will do.

Thanks for the review. Will resend in two weeks when I'm back from vacation.

Cheers!

> 
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> 
>> +{
>> +	lock_device_hotplug();
>> +	__remove_memory(nid, start, size);
>> +	unlock_device_hotplug();
>> +}
>>  EXPORT_SYMBOL_GPL(remove_memory);
>>  #endif /* CONFIG_MEMORY_HOTREMOVE */


-- 

Thanks,

David / dhildenb
