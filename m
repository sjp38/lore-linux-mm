Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6C566B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:20:47 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id s63-v6so33177059qkc.7
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:20:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b16-v6si3249457qkh.379.2018.07.12.09.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 09:20:42 -0700 (PDT)
Date: Thu, 12 Jul 2018 18:20:39 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCHv2 1/2] mm: Fix vma_is_anonymous() false-positives
Message-ID: <20180712162039.GA16175@redhat.com>
References: <20180712145626.41665-1-kirill.shutemov@linux.intel.com>
 <20180712145626.41665-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712145626.41665-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

Kirill, I am not trying to review this change (but it looks good to me),
just a silly question...

On 07/12, Kirill A. Shutemov wrote:
>
> This can be fixed by assigning anonymous VMAs own vm_ops and not relying
> on it being NULL.

I agree, this makes sense, but...

> If ->mmap() failed to set ->vm_ops, mmap_region() will set it to
> dummy_vm_ops.

Shouldn't this change alone fix the problem?

Oleg.
