Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD0B6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 13:58:14 -0400 (EDT)
Received: by mail-ob0-f177.google.com with SMTP id gq1so8305630obb.36
        for <linux-mm@kvack.org>; Mon, 12 May 2014 10:58:13 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id ap2si6695440pbc.218.2014.05.12.10.58.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 10:58:13 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so9036754pab.21
        for <linux-mm@kvack.org>; Mon, 12 May 2014 10:58:12 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: Re: [PATCH 2/3] mm: use a light-weight __mod_zone_page_state in mlocked_vma_newpage() 
Date: Tue, 13 May 2014 01:58:01 +0800
Message-Id: <1399917481-28917-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, nasa4836@gmail.com, sasha.levin@oracle.com, zhangyanfei@cn.fujitsu.com, oleg@redhat.com, fabf@skynet.be, cldu@marvell.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, schwidefsky@de.ibm.com, gorcunov@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrew, since the previous patch

 [PATCH 1/3] mm: add comment for __mod_zone_page_stat

is updated, update this one accordingly.

-----<8-----
