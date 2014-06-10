Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 236B16B0100
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 11:34:30 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id x12so4785982wgg.34
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 08:34:29 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id ez4si17376234wib.65.2014.06.10.08.34.28
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 08:34:28 -0700 (PDT)
Date: Tue, 10 Jun 2014 18:34:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: missing check in __get_user_pages
Message-ID: <20140610153427.GC3728@node.dhcp.inet.fi>
References: <20140610145439.GA17556@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140610145439.GA17556@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: linux-mm@kvack.org

On Tue, Jun 10, 2014 at 10:54:39AM -0400, Dave Jones wrote:
> coverity flagged this code in __get_user_pages
> 
> 448                         if (is_vm_hugetlb_page(vma)) {
> 449                                 i = follow_hugetlb_page(mm, vma, pages, vmas,
> 450                                                 &start, &nr_pages, i,
> 451                                                 gup_flags);
> 452                                 continue;
> 453                         }
> 
> It seems unaware that follow_hugetlb_page can in some cases return -EFAULT.
> I'm not sure if this is triggerable, but it looks dangerous.

Looks like follow_hugetlb_page() sets nr_pages to 0 in this case, and
__get_user_pages() can handle this correctly.

But, yes, it's ugly.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
