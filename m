Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4000B6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 16:08:29 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so45031298wic.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 13:08:28 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id m8si28430126wjw.183.2015.09.15.13.08.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 13:08:28 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so44698580wic.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 13:08:27 -0700 (PDT)
Date: Tue, 15 Sep 2015 23:08:21 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [RFC v5 2/3] mm: make optimistic check for swapin readahead
Message-ID: <20150915200820.GA4188@debian>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
 <1442259105-4420-3-git-send-email-ebru.akagunduz@gmail.com>
 <20150914143355.cd75506c0605c5d6c9a4bb03@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914143355.cd75506c0605c5d6c9a4bb03@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Mon, Sep 14, 2015 at 02:33:55PM -0700, Andrew Morton wrote:
> On Mon, 14 Sep 2015 22:31:44 +0300 Ebru Akagunduz <ebru.akagunduz@gmail.com> wrote:
> 
> > This patch introduces new sysfs integer knob
> > /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
> > which makes optimistic check for swapin readahead to
> > increase thp collapse rate. Before getting swapped
> > out pages to memory, checks them and allows up to a
> > certain number. It also prints out using tracepoints
> > amount of unmapped ptes.
> 
> We we please get this control documented? 
> Documentation/vm/transhuge.txt appears to be the place for it.

I will add annotation about max_swap_ptes to doc and send it with new patch.

Kind regards,
Ebru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
