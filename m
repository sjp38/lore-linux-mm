Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCE96B0008
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 19:16:47 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b95-v6so19689891plb.10
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 16:16:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b11-v6si14109641pgw.517.2018.10.16.16.16.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 16:16:46 -0700 (PDT)
Date: Tue, 16 Oct 2018 16:16:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-Id: <20181016161643.9c16164889b4d99d6eff6763@linux-foundation.org>
In-Reply-To: <20181016231149.GJ30832@redhat.com>
References: <20181009094825.GC6931@suse.de>
	<20181009122745.GN8528@dhcp22.suse.cz>
	<20181009130034.GD6931@suse.de>
	<20181009142510.GU8528@dhcp22.suse.cz>
	<20181009230352.GE9307@redhat.com>
	<alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
	<alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
	<20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
	<20181016074606.GH6931@suse.de>
	<20181016153715.b40478ff2eebe8d6cf1aead5@linux-foundation.org>
	<20181016231149.GJ30832@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Tue, 16 Oct 2018 19:11:49 -0400 Andrea Arcangeli <aarcange@redhat.com> wrote:

> This was a severe regression
> compared to previous kernels that made important workloads unusable
> and it starts when __GFP_THISNODE was added to THP allocations under
> MADV_HUGEPAGE. It is not a significant risk to go to the previous
> behavior before __GFP_THISNODE was added, it worked like that for
> years.

5265047ac301 ("mm, thp: really limit transparent hugepage allocation to
local node") was April 2015.  That's a long time for a "severe
regression" to go unnoticed?
