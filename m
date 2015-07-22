Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA069003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:06:49 -0400 (EDT)
Received: by igr7 with SMTP id 7so79269809igr.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:06:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k3si3215021igx.18.2015.07.22.15.06.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 15:06:49 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:06:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 00/10] hugetlbfs: add fallocate support
Message-Id: <20150722150647.2597c7e5be9ee1eecc438b6f@linux-foundation.org>
In-Reply-To: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>

On Tue, 21 Jul 2015 11:09:34 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> As suggested during the RFC process, tests have been proposed to
> libhugetlbfs as described at:
> http://librelist.com/browser//libhugetlbfs/2015/6/25/patch-tests-add-tests-for-fallocate-system-call/

I didn't know that libhugetlbfs has tests.  I wonder if that makes
tools/testing/selftests/vm's hugetlbfstest harmful?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
