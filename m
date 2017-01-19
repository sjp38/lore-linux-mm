Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD4F16B02BC
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 13:15:18 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id u8so4862281ywu.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 10:15:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j36si3118602qta.209.2017.01.19.10.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 10:15:18 -0800 (PST)
Date: Thu, 19 Jan 2017 19:15:14 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] userfaultfd: non-cooperative: add madvise() event
 for MADV_REMOVE request
Message-ID: <20170119181514.GO10177@redhat.com>
References: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org

On Thu, Jan 19, 2017 at 10:22:31AM +0200, Mike Rapoport wrote:
> Hi,
> 
> These patches add notification of madvise(MADV_REMOVE) event to
> non-cooperative userfaultfd monitor.
> 
> The first pacth renames EVENT_MADVDONTNEED to EVENT_REMOVE along with
> relevant functions and structures. Using _REMOVE instead of _MADVDONTNEED
> describes the event semantics more clearly and I hope it's not too late for
> such change in the ABI.
> 
> The patches are against current -mm tree.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Not sure if they should be folded inside -mm before they go upstream,
but if they're sent all along it probably doesn't make a difference,
it just adds one more handler.

In theory we could have differentiated MADV_REMOVE and MADV_DONTNEED
in two different events, but I couldn't see any downside in sharing
the same event for both and this looks more compact.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
