Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 77B63900002
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 15:21:20 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id q107so6406251qgd.28
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 12:21:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 93si17203732qgk.108.2014.08.01.12.21.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Aug 2014 12:21:19 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v6 00/13] pagewalk: improve vma handling, apply to new users
Date: Fri,  1 Aug 2014 15:20:36 -0400
Message-Id: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

This series is ver.6 of page table walker patchset.
I just rebased this onto mmotm-2014-07-30-15-57 with no major change.
Trinity shows no bug at least in my environment.

Thanks,
Naoya Horiguchi

Tree: git@github.com:Naoya-Horiguchi/linux.git
Branch: mmotm-2014-07-30-15-57/page_table_walker.ver6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
