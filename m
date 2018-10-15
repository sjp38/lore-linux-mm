Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B13E6B0003
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 18:45:02 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id f59-v6so16832377plb.5
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 15:45:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t29-v6si12174405pgn.442.2018.10.15.15.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 15:45:01 -0700 (PDT)
Date: Mon, 15 Oct 2018 15:44:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-Id: <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
References: <20180925120326.24392-2-mhocko@kernel.org>
	<alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
	<20181005073854.GB6931@suse.de>
	<alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
	<20181005232155.GA2298@redhat.com>
	<alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
	<20181009094825.GC6931@suse.de>
	<20181009122745.GN8528@dhcp22.suse.cz>
	<20181009130034.GD6931@suse.de>
	<20181009142510.GU8528@dhcp22.suse.cz>
	<20181009230352.GE9307@redhat.com>
	<alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
	<alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Mon, 15 Oct 2018 15:30:17 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> At the risk of beating a dead horse that has already been beaten, what are 
> the plans for this patch when the merge window opens?

I'll hold onto it until we've settled on something.  Worst case,
Andrea's original is easily backportable.

>  It would be rather 
> unfortunate for us to start incurring a 14% increase in access latency and 
> 40% increase in fault latency.

Yes.

>  Would it be possible to test with my 
> patch[*] that does not try reclaim to address the thrashing issue?

Yes please.

And have you been able to test it with the sort of workloads which
Andrea is attempting to address?
