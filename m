Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id ABD516B00FA
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 10:54:48 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id i17so2277780qcy.8
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 07:54:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e10si27855645qai.96.2014.06.10.07.54.47
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 07:54:48 -0700 (PDT)
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s5AEskc2025065
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 10:54:47 -0400
Received: from gelk.kernelslacker.org (ovpn-113-136.phx2.redhat.com [10.3.113.136])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s5AEseVa024705
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 10:54:46 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.8/8.14.7) with ESMTP id s5AEseJi017866
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 10:54:40 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.8/8.14.8/Submit) id s5AEsdo3017865
	for linux-mm@kvack.org; Tue, 10 Jun 2014 10:54:39 -0400
Date: Tue, 10 Jun 2014 10:54:39 -0400
From: Dave Jones <davej@redhat.com>
Subject: missing check in __get_user_pages
Message-ID: <20140610145439.GA17556@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

coverity flagged this code in __get_user_pages

448                         if (is_vm_hugetlb_page(vma)) {
449                                 i = follow_hugetlb_page(mm, vma, pages, vmas,
450                                                 &start, &nr_pages, i,
451                                                 gup_flags);
452                                 continue;
453                         }

It seems unaware that follow_hugetlb_page can in some cases return -EFAULT.
I'm not sure if this is triggerable, but it looks dangerous.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
