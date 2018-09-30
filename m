Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5788E0001
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 02:34:09 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f19-v6so10360863qtp.6
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 23:34:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i6-v6si804775qtj.167.2018.09.29.23.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Sep 2018 23:34:08 -0700 (PDT)
Date: Sun, 30 Sep 2018 14:34:01 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH 1/3] userfaultfd: selftest: cleanup help messages
Message-ID: <20180930063401.GA18728@xz-x1>
References: <20180929084311.15600-1-peterx@redhat.com>
 <20180929084311.15600-2-peterx@redhat.com>
 <20180929102811.GA6429@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180929102811.GA6429@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Shuah Khan <shuah@kernel.org>, Jerome Glisse <jglisse@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kselftest@vger.kernel.org, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Sep 29, 2018 at 01:28:12PM +0300, Mike Rapoport wrote:

[...]

> > +const char *examples =
> > +    "# 100MiB 99999 bounces\n"
> > +    "./userfaultfd anon 100 99999\n"
> > +    "\n"
> > +    "# 1GiB 99 bounces\n"
> > +    "./userfaultfd anon 1000 99\n"
> > +    "\n"
> > +    "# 10MiB-~6GiB 999 bounces, continue forever unless an error triggers\n"
> > +    "while ./userfaultfd anon $[RANDOM % 6000 + 10] 999; do true; done\n"
> > +    "\n";
> 
> While at it, can you please update the examples to include other test
> types?

Sure thing.

Thanks for the quick review!

Regards,

-- 
Peter Xu
