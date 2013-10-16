Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 703436B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 13:50:40 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so1130115pbc.31
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 10:50:40 -0700 (PDT)
Received: by mail-vb0-f51.google.com with SMTP id x16so526764vbf.24
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 10:50:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131016121145.EFC7AE0090@blue.fi.intel.com>
References: <20131015001214.GD3432@hippobay.mtv.corp.google.com>
 <20131015102912.2BC99E0090@blue.fi.intel.com> <CACz4_2eh3F2An9F0GxSvw8kSmn2VZbqbdRVGXA2B=gvPFCChUw@mail.gmail.com>
 <20131016121145.EFC7AE0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Wed, 16 Oct 2013 10:50:17 -0700
Message-ID: <CACz4_2fcnV6UQQU9pKu0cF0MTzC7wu+X_swvyOwmgw0sTxZWWA@mail.gmail.com>
Subject: Re: [PATCH 03/12] mm, thp, tmpfs: handle huge page cases in shmem_getpage_gfp
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Great! Thanks!
Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Wed, Oct 16, 2013 at 5:11 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Ning Qu wrote:
>> you mean something like this? If so, then fixed.
>>
>>                if (must_use_thp) {
>>                         page =3D shmem_alloc_hugepage(gfp, info, index);
>>                         if (page) {
>>                                 count_vm_event(THP_WRITE_ALLOC);
>>                         } else
>>                                 count_vm_event(THP_WRITE_ALLOC_FAILED);
>>                 } else {
>>                         page =3D shmem_alloc_page(gfp, info, index);
>>                 }
>>
>>                 if (!page) {
>>                         error =3D -ENOMEM;
>>                         goto unacct;
>>                 }
>>                 nr =3D hpagecache_nr_pages(page);
>
> Yeah.
>
> count_vm_event() part still looks ugly, but I have similar in my code.
> I'll think more how to rework in to make it better.
>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
