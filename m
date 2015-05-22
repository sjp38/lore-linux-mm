Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 51E46829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:50:32 -0400 (EDT)
Received: by wgez8 with SMTP id z8so29035770wge.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:50:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si5817204wjy.71.2015.05.22.14.50.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 May 2015 14:50:30 -0700 (PDT)
Message-ID: <1432331412.2185.10.camel@stgolabs.net>
Subject: Re: [RFC v3 PATCH 00/10] hugetlbfs: add fallocate support
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 22 May 2015 14:50:12 -0700
In-Reply-To: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On Thu, 2015-05-21 at 08:47 -0700, Mike Kravetz wrote:
> This patch set adds fallocate functionality to hugetlbfs.

It would be good to also have proper testcases in, say, libhugetlbfs.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
