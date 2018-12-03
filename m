Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6D56B6B0A
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 15:58:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so7192762edd.2
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 12:58:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f47sor8103698edb.4.2018.12.03.12.58.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 12:58:37 -0800 (PST)
Date: Mon, 3 Dec 2018 20:58:36 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH RFCv2 1/4] mm/memory_hotplug: Introduce memory block types
Message-ID: <20181203205836.7xpab6ljc3kngrqm@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181130175922.10425-1-david@redhat.com>
 <20181130175922.10425-2-david@redhat.com>
 <20181201012507.lxfscl6ho3gc6gnn@master>
 <af797dbb-0537-19ec-ef31-d72a3f979791@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af797dbb-0537-19ec-ef31-d72a3f979791@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, xen-devel@lists.xenproject.org, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Banman <andrew.banman@hpe.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Oscar Salvador <osalvador@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Michal Such??nek <msuchanek@suse.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

[...]
>>>
>>> +	if (type == MEMORY_BLOCK_NONE)
>>> +		return -EINVAL;
>> 
>> No one will pass in this value. Can we omit this check for now?
>
>I could move it to patch nr 2 I guess, but as I introduce
>MEMORY_BLOCK_NONE here it made sense to keep it in here.
>

Yes, this make sense to me now.

>(and I think at least for now it makes sense to not squash patch 1 and
>2, to easier discuss the new user interface/concept introduced in this
>patch).
>
>Thanks!
>
>-- 
>
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me
