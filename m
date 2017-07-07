Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 467726B02FD
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 13:12:41 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id p193so13568485vkd.11
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 10:12:41 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 52si1966649uah.167.2017.07.07.10.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 10:12:40 -0700 (PDT)
Subject: Re: [RFC PATCH 0/1] mm/mremap: add MREMAP_MIRROR flag
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <0f935c5a-2580-c95a-4ea5-c25e796dad03@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <7a5d293b-44d7-b0f4-20e5-6a3428c25ed2@oracle.com>
Date: Fri, 7 Jul 2017 10:12:32 -0700
MIME-Version: 1.0
In-Reply-To: <0f935c5a-2580-c95a-4ea5-c25e796dad03@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 07/07/2017 04:03 AM, Anshuman Khandual wrote:
> On 07/06/2017 09:47 PM, Mike Kravetz wrote:
>> The mremap system call has the ability to 'mirror' parts of an existing
>> mapping.  To do so, it creates a new mapping that maps the same pages as
>> the original mapping, just at a different virtual address.  This
>> functionality has existed since at least the 2.6 kernel [1].  A comment
>> was added to the code to help preserve this feature.
> 
> In mremap() implementation move_vma() attempts to do do_unmap() after
> move_page_tables(). do_unmap() on the original VMA bails out because
> the requested length being 0. Hence both the original VMA and the new
> VMA remains after the page table migration. Seems like this whole
> mirror function is by coincidence or it has been designed that way ?

I honestly do not know.  From what I can tell, the functionality existed
in 2.4.  The email thread [1], exists because it was 'accidentally' removed
in 2.6.  All of this is before git history (and my involvement).

My 'guess' is that this functionality was created by coincidence.  Someone
noticed it and took advantage of it.  When it was removed, their code broke. 
The code was 'fixed' and a comment was added to the code in an attempt to
prevent removing the functionality in the future.  Again, this is speculation
as I was not originally involved.

The point of this RFC is to consider adding the functionality to the API.
If we are carrying the functionality in the code, we should at least document
so that application programmers can take advantage of it.

[1] https://lkml.org/lkml/2004/1/12/260
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
