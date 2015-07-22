Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id D401E9003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:37:55 -0400 (EDT)
Received: by ietj16 with SMTP id j16so178795828iet.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:37:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n10si14233531igv.28.2015.07.22.15.37.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 15:37:55 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:37:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 00/10] hugetlbfs: add fallocate support
Message-Id: <20150722153753.08f0a221023706d4ed1cc575@linux-foundation.org>
In-Reply-To: <1437604474.3298.7.camel@stgolabs.net>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
	<20150722150647.2597c7e5be9ee1eecc438b6f@linux-foundation.org>
	<1437603594.3298.5.camel@stgolabs.net>
	<20150722153023.e8f15eb4e490f79cc029c8cd@linux-foundation.org>
	<1437604474.3298.7.camel@stgolabs.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 22 Jul 2015 15:34:34 -0700 Davidlohr Bueso <dave@stgolabs.net> wrote:

> On Wed, 2015-07-22 at 15:30 -0700, Andrew Morton wrote:
> > selftests is a pretty scrappy place.  It's partly a dumping ground for
> > things so useful test code doesn't just get lost and bitrotted.  Partly
> > a framework so people who add features can easily test them. Partly to
> > provide tools to architecture maintainers when they wire up new
> > syscalls and the like.
> 
> Yeah, ipc, for instance, also sucks _badly_ in selftests.

What testsuite should people be using for IPC?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
