Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2DFF36B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 10:14:59 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y68so558376860pfb.6
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 07:14:59 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p125si19886829pfp.119.2016.12.06.07.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 07:14:58 -0800 (PST)
Subject: Re: [PATCH] mm: make transparent hugepage size public
References: <alpine.LSU.2.11.1612052200290.13021@eggly.anvils>
 <877f7difx1.fsf@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <85c787f4-36ff-37fe-ff93-e42bad4b7c1e@intel.com>
Date: Tue, 6 Dec 2016 07:14:50 -0800
MIME-Version: 1.0
In-Reply-To: <877f7difx1.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On 12/06/2016 01:07 AM, Aneesh Kumar K.V wrote:
> Hugh Dickins <hughd@google.com> writes:
> 
>> Test programs want to know the size of a transparent hugepage.
>> While it is commonly the same as the size of a hugetlbfs page
>> (shown as Hugepagesize in /proc/meminfo), that is not always so:
>> powerpc implements transparent hugepages in a different way from
>> hugetlbfs pages, so it's coincidence when their sizes are the same;
>> and x86 and others can support more than one hugetlbfs page size.
>>
>> Add /sys/kernel/mm/transparent_hugepage/hpage_pmd_size to show the
>> THP size in bytes - it's the same for Anonymous and Shmem hugepages.
>> Call it hpage_pmd_size (after HPAGE_PMD_SIZE) rather than hpage_size,
>> in case some transparent support for pud and pgd pages is added later.
> 
> We have in /proc/meminfo
> 
> Hugepagesize:       2048 kB
> 
> Does it makes it easy for application to find THP page size also there ?

Nope.  That's the default hugetlbfs page size.  Even on x86, that can be
changed and _could_ be 1G.  If hugetlbfs is configured out, you also
won't get this in meminfo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
