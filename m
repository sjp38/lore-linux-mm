Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF556B000A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 03:08:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x10-v6so16130251edx.9
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 00:08:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f7-v6si4371583edd.297.2018.10.17.00.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 00:08:27 -0700 (PDT)
Date: Wed, 17 Oct 2018 09:08:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181017070825.GD18839@dhcp22.suse.cz>
References: <20181009130034.GD6931@suse.de>
 <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com>
 <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
 <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
 <20181016074606.GH6931@suse.de>
 <20181016153715.b40478ff2eebe8d6cf1aead5@linux-foundation.org>
 <20181016231149.GJ30832@redhat.com>
 <20181016161643.9c16164889b4d99d6eff6763@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181016161643.9c16164889b4d99d6eff6763@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Tue 16-10-18 16:16:43, Andrew Morton wrote:
> On Tue, 16 Oct 2018 19:11:49 -0400 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > This was a severe regression
> > compared to previous kernels that made important workloads unusable
> > and it starts when __GFP_THISNODE was added to THP allocations under
> > MADV_HUGEPAGE. It is not a significant risk to go to the previous
> > behavior before __GFP_THISNODE was added, it worked like that for
> > years.@s1@s2@s1
> 
> 5265047ac301 ("mm, thp: really limit transparent hugepage allocation to
> local node") was April 2015.  That's a long time for a "severe
> regression" to go unnoticed?

Well, it gets some time to adopt changes in enterprise and we start
seeing people reporting this issue. That is why I believe we should
start with something really simple and stable tree backportable first
and then build something more complex on top.
-- 
Michal Hocko
SUSE Labs
