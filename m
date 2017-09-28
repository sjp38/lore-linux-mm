Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEA76B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 06:16:41 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d70so1368762qkc.3
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 03:16:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o65si1155034qka.380.2017.09.28.03.16.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 03:16:40 -0700 (PDT)
Date: Thu, 28 Sep 2017 12:16:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] userfaultfd: non-cooperative: fix fork fctx->new
 memleak
Message-ID: <20170928101637.GG30973@redhat.com>
References: <20170302173738.18994-1-aarcange@redhat.com>
 <20170302173738.18994-2-aarcange@redhat.com>
 <CA+1xoqc0W4CXEJ-hXL5=KnzskazR1E2p+rQuEop_Y0tHoanyUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+1xoqc0W4CXEJ-hXL5=KnzskazR1E2p+rQuEop_Y0tHoanyUA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, alexander.levin@verizon.com

Hello Sasha,

On Thu, Sep 28, 2017 at 02:26:42AM -0700, Sasha Levin wrote:
> On Thu, Mar 2, 2017 at 9:37 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> >
> > We have a memleak in the ->new ctx if the uffd of the parent is closed
> > before the fork event is read, nothing frees the new context.
> 
> Hey Mike,
> 
> This seems to result in the following:

Andrew just included this fix in -mm:

https://lkml.org/lkml/2017/9/20/571

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
