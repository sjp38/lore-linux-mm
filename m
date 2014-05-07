Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id A00CA6B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 00:28:55 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id rp18so448327iec.8
        for <linux-mm@kvack.org>; Tue, 06 May 2014 21:28:55 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id p6si12262630icc.155.2014.05.06.21.28.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 21:28:55 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so479165ier.40
        for <linux-mm@kvack.org>; Tue, 06 May 2014 21:28:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1399429930-5073-1-git-send-email-xindong.ma@intel.com>
References: <1399429930-5073-1-git-send-email-xindong.ma@intel.com>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Wed, 7 May 2014 12:28:14 +0800
Message-ID: <CAHz2CGUo2SevOPXw7PqNyUroc4xD2Z4fOHEFUeJ+FQU-6rib0g@mail.gmail.com>
Subject: Re: [PATCH] rmap: validate pointer in anon_vma_clone
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Ma <xindong.ma@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, iamjoonsoo.kim@lge.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kirill.shutemov@linux.intel.com, gorcunov@gmail.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 7, 2014 at 10:32 AM, Leon Ma <xindong.ma@intel.com> wrote:
> If memory allocation failed in first loop, root will be NULL and
> will lead to kernel panic.

Hello, Leon,

I am afraid not.  unlock_anon_vma_root() has a sanity check NULLness of root,
so it is impossible to panic for a dangling root pointer.



Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
