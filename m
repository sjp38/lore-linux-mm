Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2AE6B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 17:33:58 -0400 (EDT)
Received: by qgev79 with SMTP id v79so126947207qge.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 14:33:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d93si14004658qkh.88.2015.09.14.14.33.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 14:33:57 -0700 (PDT)
Date: Mon, 14 Sep 2015 14:33:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v5 2/3] mm: make optimistic check for swapin readahead
Message-Id: <20150914143355.cd75506c0605c5d6c9a4bb03@linux-foundation.org>
In-Reply-To: <1442259105-4420-3-git-send-email-ebru.akagunduz@gmail.com>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
	<1442259105-4420-3-git-send-email-ebru.akagunduz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Mon, 14 Sep 2015 22:31:44 +0300 Ebru Akagunduz <ebru.akagunduz@gmail.com> wrote:

> This patch introduces new sysfs integer knob
> /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
> which makes optimistic check for swapin readahead to
> increase thp collapse rate. Before getting swapped
> out pages to memory, checks them and allows up to a
> certain number. It also prints out using tracepoints
> amount of unmapped ptes.

We we please get this control documented? 
Documentation/vm/transhuge.txt appears to be the place for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
