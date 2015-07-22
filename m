Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B7B389003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:54:12 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so70201wic.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:54:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5si5995274wix.107.2015.07.22.15.54.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 15:54:11 -0700 (PDT)
Message-ID: <1437605640.3298.16.camel@stgolabs.net>
Subject: Re: [PATCH v4 00/10] hugetlbfs: add fallocate support
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 22 Jul 2015 15:54:00 -0700
In-Reply-To: <1437605459.3298.14.camel@stgolabs.net>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
	 <20150722150647.2597c7e5be9ee1eecc438b6f@linux-foundation.org>
	 <1437603594.3298.5.camel@stgolabs.net>
	 <20150722153023.e8f15eb4e490f79cc029c8cd@linux-foundation.org>
	 <1437604474.3298.7.camel@stgolabs.net>
	 <20150722153753.08f0a221023706d4ed1cc575@linux-foundation.org>
	 <1437605459.3298.14.camel@stgolabs.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 2015-07-22 at 15:50 -0700, Davidlohr Bueso wrote:
> On Wed, 2015-07-22 at 15:37 -0700, Andrew Morton wrote:
> > On Wed, 22 Jul 2015 15:34:34 -0700 Davidlohr Bueso <dave@stgolabs.net> wrote:
> > 
> > > On Wed, 2015-07-22 at 15:30 -0700, Andrew Morton wrote:
> > > > selftests is a pretty scrappy place.  It's partly a dumping ground for
> > > > things so useful test code doesn't just get lost and bitrotted.  Partly
> > > > a framework so people who add features can easily test them. Partly to
> > > > provide tools to architecture maintainers when they wire up new
> > > > syscalls and the like.
> > > 
> > > Yeah, ipc, for instance, also sucks _badly_ in selftests.
> > 
> > What testsuite should people be using for IPC?
> 
> The best I've found is using the ipc parts of LTP. It's caught a lot of
> bugs in the past. Unsurprisingly, I believe Fengguang has this
> automated.
> 
> Manfred also has a few for more specific purposes -- which also serve
> for performance testing:
> https://github.com/manfred-colorfu/ipcsemtest
> https://github.com/manfred-colorfu/ipcscale
> 
> iirc Dave Hansen also had written some shm-specific tests.

I also used to rely on multiple Oracle 11g RDBMS workloads and
benchmarks, particularly for dealing with sysv sems. Unfortunately I no
longer have the required licenses :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
