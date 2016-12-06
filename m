Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8CBC6B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 12:19:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so30438016pgc.1
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 09:19:43 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k1si20238067plb.309.2016.12.06.09.19.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 09:19:43 -0800 (PST)
Date: Tue, 6 Dec 2016 20:19:05 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] mm: make transparent hugepage size public
Message-ID: <20161206171905.n7qwvfb5sjxn3iif@black.fi.intel.com>
References: <alpine.LSU.2.11.1612052200290.13021@eggly.anvils>
 <877f7difx1.fsf@linux.vnet.ibm.com>
 <85c787f4-36ff-37fe-ff93-e42bad4b7c1e@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <85c787f4-36ff-37fe-ff93-e42bad4b7c1e@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Tue, Dec 06, 2016 at 07:14:50AM -0800, Dave Hansen wrote:
> On 12/06/2016 01:07 AM, Aneesh Kumar K.V wrote:
> > Hugh Dickins <hughd@google.com> writes:
> > 
> >> Test programs want to know the size of a transparent hugepage.
> >> While it is commonly the same as the size of a hugetlbfs page
> >> (shown as Hugepagesize in /proc/meminfo), that is not always so:
> >> powerpc implements transparent hugepages in a different way from
> >> hugetlbfs pages, so it's coincidence when their sizes are the same;
> >> and x86 and others can support more than one hugetlbfs page size.
> >>
> >> Add /sys/kernel/mm/transparent_hugepage/hpage_pmd_size to show the
> >> THP size in bytes - it's the same for Anonymous and Shmem hugepages.
> >> Call it hpage_pmd_size (after HPAGE_PMD_SIZE) rather than hpage_size,
> >> in case some transparent support for pud and pgd pages is added later.
> > 
> > We have in /proc/meminfo
> > 
> > Hugepagesize:       2048 kB
> > 
> > Does it makes it easy for application to find THP page size also there ?
> 
> Nope.  That's the default hugetlbfs page size.  Even on x86, that can be
> changed and _could_ be 1G.  If hugetlbfs is configured out, you also
> won't get this in meminfo.

I think Aneesh propose to add one more line into the file.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
