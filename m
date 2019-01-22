Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82B1F8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 22:18:18 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w28so20657320qkj.22
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 19:18:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g188si729579qkf.215.2019.01.21.19.18.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 19:18:17 -0800 (PST)
Date: Tue, 22 Jan 2019 11:18:03 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH RFC 00/24] userfaultfd: write protection support
Message-ID: <20190122031803.GB7669@xz-x1>
References: <20190121075722.7945-1-peterx@redhat.com>
 <c2485a2d-25b3-2fc0-4902-01fa278be9c7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <c2485a2d-25b3-2fc0-4902-01fa278be9c7@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Jan 21, 2019 at 03:33:21PM +0100, David Hildenbrand wrote:

[...]

> Does this series fix the "false positives" case I experienced on early
> prototypes of uffd-wp? (getting notified about a write access although
> it was not a write access?)

Hi, David,

Yes it should solve it.

The early prototype in Andrea's tree hasn't yet applied the new
PTE/swap bits for uffd-wp hence it was not able to avoid those fause
positives.  This series has applied all those ideas (which actually
come from Andrea as well) so the protection information will be
persisent per PTE rather than per VMA and it will be kept even through
swapping and page migrations.

Thanks,

-- 
Peter Xu
