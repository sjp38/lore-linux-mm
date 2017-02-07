Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 388E46B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 15:06:58 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id h56so118568331qtc.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 12:06:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d31si3770852qkh.193.2017.02.07.12.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 12:06:57 -0800 (PST)
Date: Tue, 7 Feb 2017 21:06:54 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd: mcopy_atomic: update cases returning -ENOENT
Message-ID: <20170207200654.GK25530@redhat.com>
References: <20170207150249.GA6709@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207150249.GA6709@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 07, 2017 at 05:02:50PM +0200, Mike Rapoport wrote:
> Hello Andrew,
> 
> The patch below is an incremental fixup for concerns Andrea raised at [1].
> Please let me know if you prefer me to update the original patch and
> resend.
> 
> [1] http://www.spinics.net/lists/linux-mm/msg121267.html
> 
> --
> Sincerely yours,
> Mike.
> 
> From 8acff65ecee8ca4cc892d35b45125c34568d1c93 Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Date: Tue, 7 Feb 2017 11:50:17 +0200
> Subject: [PATCH] userfaultfd: mcopy_atomic: update cases returning -ENOENT
> 
> As Andrea commented in [1], if the VMA covering the address was unmapped,
> we may end up with a VMA a way above the faulting address. In this case we
> would like to return -ENOENT to allow uffd monitor detection of VMA
> removal.
> 
> [1] http://www.spinics.net/lists/linux-mm/msg121267.html
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
