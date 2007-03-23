Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id l2NMeN4A028513
	for <linux-mm@kvack.org>; Fri, 23 Mar 2007 15:40:24 -0700
Received: from an-out-0708.google.com (ancc5.prod.google.com [10.100.29.5])
	by zps76.corp.google.com with ESMTP id l2NMdpqh018332
	for <linux-mm@kvack.org>; Fri, 23 Mar 2007 15:40:22 -0700
Received: by an-out-0708.google.com with SMTP id c5so1312636anc
        for <linux-mm@kvack.org>; Fri, 23 Mar 2007 15:40:22 -0700 (PDT)
Message-ID: <b040c32a0703231540i56da0877o3da11fcd5929b4e2@mail.gmail.com>
Date: Fri, 23 Mar 2007 15:40:22 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch 0/2] introduce /dev/hugetlb char device
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Introduce /dev/hugetlb device that behaves similar to /dev/zero for
allocating anonymous hugetlb page.  It is especially beneficial that
application developers can have an easy way to create MAP_PRIVATE
hugetlb mappings without all the fuss about the hugetlbfs filesystem.

Two follow on patches has more detail description for each changeset.

Signed-off-by: Ken Chen <kenchen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
