Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 359256B0392
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 16:08:57 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u108so23253829wrb.3
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 13:08:57 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id z91si20027364wrc.238.2017.03.19.13.08.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 13:08:56 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id BA94498D09
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 20:08:55 +0000 (UTC)
Date: Sun, 19 Mar 2017 20:08:49 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [HMM 03/16] mm/ZONE_DEVICE/free-page: callback when page is
 freed v3
Message-ID: <20170319200849.GD2774@techsingularity.net>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-4-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1489680335-6594-4-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J?r?me Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Mar 16, 2017 at 12:05:22PM -0400, J?r?me Glisse wrote:
> When a ZONE_DEVICE page refcount reach 1 it means it is free and nobody
> is holding a reference on it (only device to which the memory belong do).
> Add a callback and call it when that happen so device driver can implement
> their own free page management.
> 

If it does not implement it's own management then it still needs to be
freed to the main allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
