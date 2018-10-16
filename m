Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4091A6B0008
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 03:46:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e5-v6so13607292eda.4
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 00:46:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h8-v6si124991eja.18.2018.10.16.00.46.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 00:46:10 -0700 (PDT)
Date: Tue, 16 Oct 2018 08:46:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181016074606.GH6931@suse.de>
References: <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
 <20181009094825.GC6931@suse.de>
 <20181009122745.GN8528@dhcp22.suse.cz>
 <20181009130034.GD6931@suse.de>
 <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com>
 <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
 <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Mon, Oct 15, 2018 at 03:44:59PM -0700, Andrew Morton wrote:
> On Mon, 15 Oct 2018 15:30:17 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > At the risk of beating a dead horse that has already been beaten, what are 
> > the plans for this patch when the merge window opens?
> 
> I'll hold onto it until we've settled on something.  Worst case,
> Andrea's original is easily backportable.
> 

I consider this to be an unfortunate outcome. On the one hand, we have a
problem that three people can trivially reproduce with known test cases
and a patch shown to resolve the problem. Two of those three people work
on distributions that are exposed to a large number of users. On the
other, we have a problem that requires the system to be in a specific
state and an unknown workload that suffers badly from the remote access
penalties with a patch that has review concerns and has not been proven
to resolve the trivial cases. In the case of distributions, the first
patch addresses concerns with a common workload where on the other hand
we have an internal workload of a single company that is affected --
which indirectly affects many users admittedly but only one entity directly.

At the absolute minimum, a test case for the "system fragmentation incurs
access penalties for a workload" scenario that could both replicate the
fragmentation and demonstrate the problem should have been available before
the patch was rejected.  With the test case, there would be a chance that
others could analyse the problem and prototype some fixes. The test case
was requested in the thread and never produced so even if someone were to
prototype fixes, it would be dependant on a third party to test and produce
data which is a time-consuming loop. Instead, we are more or less in limbo.

-- 
Mel Gorman
SUSE Labs
