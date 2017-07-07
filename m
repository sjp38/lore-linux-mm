Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id B92EB6B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 13:15:00 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id y70so13522271vky.13
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 10:15:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 52si1969158uah.167.2017.07.07.10.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 10:15:00 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <ea962c4b-3d47-2a95-7697-2efb4e8cd2f0@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <3a43d5fa-223d-1315-513b-85d3a09a07b6@oracle.com>
Date: Fri, 7 Jul 2017 10:14:53 -0700
MIME-Version: 1.0
In-Reply-To: <ea962c4b-3d47-2a95-7697-2efb4e8cd2f0@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 07/07/2017 01:45 AM, Anshuman Khandual wrote:
> On 07/06/2017 09:47 PM, Mike Kravetz wrote:
>> The mremap system call has the ability to 'mirror' parts of an existing
>> mapping.  To do so, it creates a new mapping that maps the same pages as
>> the original mapping, just at a different virtual address.  This
>> functionality has existed since at least the 2.6 kernel.
>>
>> This patch simply adds a new flag to mremap which will make this
>> functionality part of the API.  It maintains backward compatibility with
>> the existing way of requesting mirroring (old_size == 0).
>>
>> If this new MREMAP_MIRROR flag is specified, then new_size must equal
>> old_size.  In addition, the MREMAP_MAYMOVE flag must be specified.
> 
> Yeah it all looks good. But why is this requirement that if
> MREMAP_MAYMOVE is specified then old_size and new_size must
> be equal.

No real reason.  I just wanted to clearly separate the new interface from
the old.  On second thought, it would be better to require old_size == 0
as in the legacy interface.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
