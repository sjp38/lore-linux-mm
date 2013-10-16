Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1496B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 13:49:49 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so518929pdj.14
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 10:49:49 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id ld13so542947vcb.39
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 10:49:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131016122611.69CA0E0090@blue.fi.intel.com>
References: <20131015001201.GC3432@hippobay.mtv.corp.google.com>
 <20131015100213.A0189E0090@blue.fi.intel.com> <CACz4_2er-_Xa8oRo_JJTC+HZtDTAcjJ+cNTjrXLhN0Dm7BtXFQ@mail.gmail.com>
 <20131016122611.69CA0E0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Wed, 16 Oct 2013 10:49:26 -0700
Message-ID: <CACz4_2edu+99ZQPOML=C9HOLtde699K450xOeCgK524MhsqODA@mail.gmail.com>
Subject: Re: [PATCH 02/12] mm, thp, tmpfs: support to add huge page into page
 cache for tmpfs
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Yes, I guess I can if I just put whatever inside the spin lock into a
common function. Thanks!
Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Wed, Oct 16, 2013 at 5:26 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Ning Qu wrote:
>> Yes, I can try. The code is pretty much similar with some minor differen=
ce.
>>
>> One thing I can do is to move the spin lock part (together with the
>> corresponding err handling into a common function.
>>
>> The only problem I can see right now is we need the following
>> additional line for shm:
>>
>> __mod_zone_page_state(page_zone(page), NR_SHMEM, nr);
>>
>> Which means we need to tell if it's coming from shm or not, is that OK
>> to add additional parameter just for that? Or is there any other
>> better way we can infer that information? Thanks!
>
> I think you can account NR_SHMEM after common code succeed, don't you?
>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
