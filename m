Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C8D006B0267
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 12:56:41 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u15so131863646oie.6
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 09:56:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 63si12396036itt.82.2016.11.04.09.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 09:56:41 -0700 (PDT)
Date: Fri, 4 Nov 2016 17:56:38 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25/33] userfaultfd: shmem: add userfaultfd hook for
 shared memory faults
Message-ID: <20161104165638.GS4611@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-26-git-send-email-aarcange@redhat.com>
 <07ce01d23679$c2be2670$483a7350$@alibaba-inc.com>
 <20161104154438.GD5605@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161104154438.GD5605@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, 'Mike Kravetz' <mike.kravetz@oracle.com>, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@virtuozzo.com>

On Fri, Nov 04, 2016 at 09:44:40AM -0600, Mike Rapoport wrote:
> Below is the updated patch that uses charge_mm instead of vma which might
> be not valid.

Like you said earlier the vma couldn't be NULL if fault_type wasn't
NULL, but applied as cleanup.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
