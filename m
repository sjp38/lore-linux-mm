Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC99D6B0010
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 07:13:16 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id r1-v6so5767547lfi.16
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:13:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x14-v6sor4741005lfe.80.2018.07.11.04.13.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 04:13:15 -0700 (PDT)
Date: Wed, 11 Jul 2018 14:13:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for
 large mapping
Message-ID: <20180711111311.hrh5kxdottmpdpn2@kshutemo-mobl1>
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180711103312.GH20050@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711103312.GH20050@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 11, 2018 at 12:33:12PM +0200, Michal Hocko wrote:
> this is not a small change for something that could be achieved
> from the userspace trivially (just call madvise before munmap - library
> can hide this). Most workloads will even not care about races because
> they simply do not play tricks with mmaps and userspace MM. So why do we
> want to put the additional complexity into the kernel?

As I said before, kernel latency issues have to be addressed in kernel.
We cannot rely on userspace being kind here.

-- 
 Kirill A. Shutemov
