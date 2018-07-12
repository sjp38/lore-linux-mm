Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 467246B000A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:39:26 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id s5-v6so4505198plq.4
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:39:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n14-v6sor4696207pfk.31.2018.07.12.09.39.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 09:39:22 -0700 (PDT)
Date: Thu, 12 Jul 2018 19:39:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/2] mm: Fix vma_is_anonymous() false-positives
Message-ID: <20180712163916.pzewd3nhane7af3u@kshutemo-mobl1>
References: <20180712145626.41665-1-kirill.shutemov@linux.intel.com>
 <20180712145626.41665-2-kirill.shutemov@linux.intel.com>
 <20180712162039.GA16175@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712162039.GA16175@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, Jul 12, 2018 at 06:20:39PM +0200, Oleg Nesterov wrote:
> Kirill, I am not trying to review this change (but it looks good to me),
> just a silly question...
> 
> On 07/12, Kirill A. Shutemov wrote:
> >
> > This can be fixed by assigning anonymous VMAs own vm_ops and not relying
> > on it being NULL.
> 
> I agree, this makes sense, but...
> 
> > If ->mmap() failed to set ->vm_ops, mmap_region() will set it to
> > dummy_vm_ops.
> 
> Shouldn't this change alone fix the problem?

Unfortunately, no. I've tried it before. Mapping /dev/zero with
MAP_PRIVATE hast to produce anonymous VMA. The trick with dummy_vm_ops
wouldn't be able to handle the situation.

-- 
 Kirill A. Shutemov
