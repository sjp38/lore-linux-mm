Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4256B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 22:31:08 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so1948407pbc.16
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 19:31:08 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id e6si2122717pbj.163.2014.03.13.19.31.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 19:31:07 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so1909933pdb.28
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 19:31:07 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH] A long explanation for a short patch
Date: Thu, 13 Mar 2014 19:30:45 -0700
Message-Id: <1394764246-19936-1-git-send-email-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Hi Sasha and linux-mm,

Prior to commit 309381feaee564281c3d9e90fbca8963bb7428ad, it was
possible to build MIT-licensed (non-GPL) drivers on Fedora. Fedora is
semi-unique, in that it sets CONFIG_VM_DEBUG.

Because Fedora sets CONFIG_VM_DEBUG, they end up pulling in
dump_page(), via VM_BUG_ON_PAGE, via get_page().  As one of the
authors of NVIDIA's new, open source, "UVM-Lite" kernel module, I
originally choose to use the kernel's get_page() routine from within
nvidia_uvm_page_cache.c, because get_page() has always seemed to be
very clearly intended for use by non-GPL, driver code.

So I'm hoping that making get_page() widely accessible again will not
be too controversial. We did check with Fedora first, and they
responded (https://bugzilla.redhat.com/show_bug.cgi?id=1074710#c3)
that we should try to get upstream changed, before asking Fedora
to change.  Their reasoning seems beneficial to Linux: leaving
CONFIG_DEBUG_VM set allows Fedora to help catch mm bugs.

thanks,
John h

John Hubbard (1):
  Change mm debug routines back to EXPORT_SYMBOL

 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
