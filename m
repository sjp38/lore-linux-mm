Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9A26B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 17:41:08 -0400 (EDT)
Received: by qgx61 with SMTP id 61so127447284qgx.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 14:41:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 188si14008360qhe.57.2015.09.14.14.41.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 14:41:08 -0700 (PDT)
Date: Mon, 14 Sep 2015 14:41:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v5 0/3] mm: make swapin readahead to gain more thp
 performance
Message-Id: <20150914144106.ee205c3ae3f4ec0e5202c9fe@linux-foundation.org>
In-Reply-To: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Mon, 14 Sep 2015 22:31:42 +0300 Ebru Akagunduz <ebru.akagunduz@gmail.com> wrote:

> This patch series makes swapin readahead up to a
> certain number to gain more thp performance and adds
> tracepoint for khugepaged_scan_pmd, collapse_huge_page,
> __collapse_huge_page_isolate.

I'll merge this series for testing.  Hopefully Andrea and/or Hugh will
find time for a quality think about the issue before 4.3 comes around.

It would be much better if we didn't have that sysfs knob - make the
control automatic in some fashion.

If we can't think of a way of doing that then at least let's document
max_ptes_swap very carefully.  Explain to our users what it does, why
they should care about it, how they should set about determining (ie:
measuring) its effect upon their workloads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
