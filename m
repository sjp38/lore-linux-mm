Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 505686B0370
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 06:56:05 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s15-v6so7580051iob.11
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 03:56:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s7si8895987itl.14.2018.10.29.03.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 03:56:04 -0700 (PDT)
Date: Mon, 29 Oct 2018 06:56:01 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181029105601.GB3823@redhat.com>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <20181029051752.GB16399@350D>
 <20181029090035.GE32673@dhcp22.suse.cz>
 <20181029094253.GC16399@350D>
 <20181029100834.GG32673@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181029100834.GG32673@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

Hello,

On Mon, Oct 29, 2018 at 11:08:34AM +0100, Michal Hocko wrote:
> This seems like a separate issue which should better be debugged. Please
> open a new thread describing the problem and the state of the node.

Yes, in my view it should be evaluated separately too, because it's
overall less concerning: __GFP_THISNODE there can only be set by the
root user there. So it has a chance to be legitimate behavior
there. Let's focus on solving the __GFP_THISNODE that any user in the
system can set (not only root) and cause severe and unexpected swap
storms or slowdowns to all other processes run by other users.

ls -l /sys/kernel/mm/hugepages/*/nr_hugepages

(and boot command line)

Thanks,
Andrea
