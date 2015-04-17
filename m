Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id D4AD06B0038
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 02:44:36 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so115643520pab.3
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 23:44:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id cc4si9456497pdb.9.2015.04.16.23.44.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 23:44:36 -0700 (PDT)
Date: Thu, 16 Apr 2015 23:44:35 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 4/4] mm: madvise allow remove operation for hugetlbfs
Message-ID: <20150417064435.GA21672@infradead.org>
References: <1429225378-22965-1-git-send-email-mike.kravetz@oracle.com>
 <1429225378-22965-5-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429225378-22965-5-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>

On Thu, Apr 16, 2015 at 04:02:58PM -0700, Mike Kravetz wrote:
> Now that we have hole punching support for hugetlbfs, we can
> also support the MADV_REMOVE interface to it.

Meh.  Just use fallocate for any new code..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
