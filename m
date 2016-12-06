Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65EFC6B025E
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 16:36:44 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so45329291pgd.0
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 13:36:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g34si20957804pld.184.2016.12.06.13.36.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 13:36:43 -0800 (PST)
Date: Tue, 6 Dec 2016 13:37:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: make transparent hugepage size public
Message-Id: <20161206133711.3109e092d550adc68f2f369c@linux-foundation.org>
In-Reply-To: <877f7difx1.fsf@linux.vnet.ibm.com>
References: <alpine.LSU.2.11.1612052200290.13021@eggly.anvils>
	<877f7difx1.fsf@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Tue, 06 Dec 2016 14:37:54 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Hugh Dickins <hughd@google.com> writes:
> 
> > Test programs want to know the size of a transparent hugepage.
> > While it is commonly the same as the size of a hugetlbfs page
> > (shown as Hugepagesize in /proc/meminfo), that is not always so:
> > powerpc implements transparent hugepages in a different way from
> > hugetlbfs pages, so it's coincidence when their sizes are the same;
> > and x86 and others can support more than one hugetlbfs page size.
> >
> > Add /sys/kernel/mm/transparent_hugepage/hpage_pmd_size to show the
> > THP size in bytes - it's the same for Anonymous and Shmem hugepages.
> > Call it hpage_pmd_size (after HPAGE_PMD_SIZE) rather than hpage_size,
> > in case some transparent support for pud and pgd pages is added later.
> 
> We have in /proc/meminfo
> 
> Hugepagesize:       2048 kB
> 
> Does it makes it easy for application to find THP page size also there ?
> 

Probably that would be more logical.  But I'm a bit concerned about
adding more stuff to /proc/meminfo from a performance point of view -
that file gets read from quite frequently and we've already put some
quite obscure things in there.  Probably we whould be careful about
this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
