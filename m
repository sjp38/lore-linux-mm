Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5FDA36B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 14:22:26 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so22054588qkc.3
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 11:22:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e6si14329142qgf.35.2015.09.10.11.22.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 11:22:25 -0700 (PDT)
Date: Thu, 10 Sep 2015 20:19:35 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in
	find_vma()
Message-ID: <20150910181935.GB21456@redhat.com>
References: <COL130-W64A6555222F8CEDA513171B9560@phx.gbl> <COL130-W6916929C85FB1943CC1B11B9530@phx.gbl> <COL130-W43C0C45AA4E2A7AA6361D0B9520@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <COL130-W43C0C45AA4E2A7AA6361D0B9520@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On 09/10, Chen Gang wrote:
>
> On 9/10/15 00:26, Oleg Nesterov wrote:
> >
> > The implementation looks correct. Why do you think it can be not 1st vma?
> >
>
> It is in while (rb_node) {...}.
>
> - When we set "vma = tmp", it is alreay match "addr < vm_end".

Yes,

> - If "addr>= vm_start", we return this vma (else continue searching).

This is optimization, we can stop the search because in this case
vma == tmp is obviously the 1st vma with "addr < vm_end".

I simply can't understand your concerns. Perhaps you can make a
patch, then it will be more clear what me-or-you have missed.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
