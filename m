Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 75C176B067A
	for <linux-mm@kvack.org>; Fri, 11 May 2018 14:26:51 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s143-v6so1823076lfs.9
        for <linux-mm@kvack.org>; Fri, 11 May 2018 11:26:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34-v6sor915519lfr.30.2018.05.11.11.26.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 May 2018 11:26:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180511181546.GA25613@bombadil.infradead.org>
References: <20180511180639.GA1792@jordon-HP-15-Notebook-PC> <20180511181546.GA25613@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 11 May 2018 23:56:48 +0530
Message-ID: <CAFqt6zbZw74s=Kqh=UgtZti_jJJ8UcCXVqBgXyG3vruRbqg9Yw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri, May 11, 2018 at 11:45 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, May 11, 2018 at 11:36:39PM +0530, Souptick Joarder wrote:
>>  mm/hugetlb.c | 2 +-
>>  mm/mmap.c    | 4 ++--
>>  2 files changed, 3 insertions(+), 3 deletions(-)
>
> Don't we also need to convert include/linux/mm_types.h:
>
> @@ -621,7 +621,7 @@ struct vm_special_mapping {
>          * If non-NULL, then this is called to resolve page faults
>          * on the special mapping.  If used, .pages is not checked.
>          */
> -       int (*fault)(const struct vm_special_mapping *sm,
> +       vm_fault_t (*fault)(const struct vm_special_mapping *sm,
>                      struct vm_area_struct *vma,
>                      struct vm_fault *vmf);
>
> or are you leaving that for a later patch?

Ahh, I didn't realise. No I think, we can add it as part of this
patch. Will send v3.
