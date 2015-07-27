Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id CA0676B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 19:26:56 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so59513986pdb.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 16:26:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p5si33802467par.165.2015.07.27.16.26.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 16:26:55 -0700 (PDT)
Subject: hugetlb pages not accounted for in rss
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <55B6BE37.3010804@oracle.com>
Date: Mon, 27 Jul 2015 16:26:47 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
Cc: =?UTF-8?Q?J=c3=b6rn_Engel?= <joern@purestorage.com>

I started looking at the hugetlb self tests.  The test hugetlbfstest
expects hugetlb pages to be accounted for in rss.  However, there is
no code in the kernel to do this accounting.

It looks like there was an effort to add the accounting back in 2013.
The test program made it into tree, but the accounting code did not.

The easiest way to resolve this issue would be to remove the test and
perhaps document that hugetlb pages are not accounted for in rss.
However, it does seem like a big oversight that hugetlb pages are not
accounted for in rss.  From a quick scan of the code it appears THP
pages are properly accounted for.

Thoughts?
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
