Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 328856B0038
	for <linux-mm@kvack.org>; Sun, 17 Sep 2017 21:53:08 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 93so14737729iol.2
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 18:53:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c83sor2631445ioa.240.2017.09.17.18.53.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Sep 2017 18:53:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170915213745.6821-1-mike.kravetz@oracle.com>
References: <20170915213745.6821-1-mike.kravetz@oracle.com>
From: Jann Horn <jannh@google.com>
Date: Sun, 17 Sep 2017 18:52:46 -0700
Message-ID: <CAG48ez0AAtzdQJPdW8sqj+mvYLdZezDe3x-_XgSvaN3ZwE=5GQ@mail.gmail.com>
Subject: Re: [patch] mremap.2: Add description of old_size == 0 functionality
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michael Kerrisk-manpages <mtk.manpages@gmail.com>, linux-man@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org

On Fri, Sep 15, 2017 at 2:37 PM, Mike Kravetz <mike.kravetz@oracle.com> wrote:
[...]
> A recent change was made to mremap so that an attempt to create a
> duplicate a private mapping will fail.
>
> commit dba58d3b8c5045ad89c1c95d33d01451e3964db7
> Author: Mike Kravetz <mike.kravetz@oracle.com>
> Date:   Wed Sep 6 16:20:55 2017 -0700
>
>     mm/mremap: fail map duplication attempts for private mappings
>
> This return code is also documented here.
[...]
> diff --git a/man2/mremap.2 b/man2/mremap.2
[...]
> @@ -174,7 +189,12 @@ and
>  or
>  .B MREMAP_FIXED
>  was specified without also specifying
> -.BR MREMAP_MAYMOVE .
> +.BR MREMAP_MAYMOVE ;
> +or \fIold_size\fP was zero and \fIold_address\fP does not refer to a
> +private anonymous mapping;

Shouldn't this be the other way around? "or old_size was zero and
old_address refers to a private anonymous mapping"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
