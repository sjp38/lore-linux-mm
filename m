Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB8716B007E
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 19:03:05 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d62so229636542iof.1
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 16:03:05 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id g11si18665732ioi.180.2016.04.24.16.03.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Apr 2016 16:03:05 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id k129so2712459iof.3
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 16:03:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <146152974907.13871.12611587818290919394.stgit@zurg>
References: <146152974907.13871.12611587818290919394.stgit@zurg>
Date: Sun, 24 Apr 2016 16:03:04 -0700
Message-ID: <CA+55aFy-5TUA38AE-6EiAPD0uB2g7=pNmqhjHTiT8fX_+z-q0g@mail.gmail.com>
Subject: Re: [PATCH v2] mm: enable RLIMIT_DATA by default with workaround for valgrind
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>

On Sun, Apr 24, 2016 at 1:29 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>
> This patch checks current usage also against rlim_max if rlim_cur is zero.
> This is safe because task anyway can increase rlim_cur up to rlim_max.
> Size of brk is still checked against rlim_cur, so this part is completely
> compatible - zero rlim_cur forbids brk() but allows private mmap().

Ack. And I'll assume this comes through -mm like the original patches did.

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
