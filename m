Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0EFA8680DC6
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 13:26:50 -0400 (EDT)
Received: by qgt47 with SMTP id 47so132336027qgt.2
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 10:26:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s28si15178537qkl.50.2015.10.04.10.26.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Oct 2015 10:26:49 -0700 (PDT)
Date: Sun, 4 Oct 2015 19:26:45 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/mmap.c: Remove redundant vma looping
Message-ID: <20151004172645.GO19466@redhat.com>
References: <COL130-W38E921DBAB9CFCFCC45F73B94A0@phx.gbl>
 <CAFLxGvyFeyV+kNoD5+4jzfid5dgkZP0uhhQ7Q7Dk-ObDJq4ByA@mail.gmail.com>
 <BLU436-SMTP233624CAE8A4C054B5DFFF8B9490@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLU436-SMTP233624CAE8A4C054B5DFFF8B9490@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "oleg@redhat.com" <oleg@redhat.com>, "asha.levin@oracle.com" <asha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

Hello Chen,

On Sun, Oct 04, 2015 at 12:55:29PM +0800, Chen Gang wrote:
> Theoretically, the lock and unlock need to be symmetric, if we have to
> lock f_mapping all firstly, then lock all anon_vma, probably, we also
> need to unlock anon_vma all, then unlock all f_mapping.

They don't need to be symmetric because the unlocking order doesn't
matter. To avoid lock inversion deadlocks it is enough to enforce the
lock order.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
