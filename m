Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34E296B0038
	for <linux-mm@kvack.org>; Sat,  8 Apr 2017 13:59:21 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id c18so21376120ioa.8
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 10:59:21 -0700 (PDT)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id 204si2983068itz.38.2017.04.08.10.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Apr 2017 10:59:20 -0700 (PDT)
Received: by mail-it0-x22b.google.com with SMTP id a140so8275636ita.0
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 10:59:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1491634091-18817-1-git-send-email-salls@cs.ucsb.edu>
References: <1491634091-18817-1-git-send-email-salls@cs.ucsb.edu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 8 Apr 2017 10:59:19 -0700
Message-ID: <CA+55aFxY=3AhkOAbDYgWHNrOaBP1q0efi2rWQBQ_Z3ZzUYH1+Q@mail.gmail.com>
Subject: Re: [PATCH] mm/mempolicy.c: fix error handling in set_mempolicy and mbind.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Salls <salls@cs.ucsb.edu>
Cc: linux-mm <linux-mm@kvack.org>, "security@kernel.org" <security@kernel.org>

On Fri, Apr 7, 2017 at 11:48 PM, Chris Salls <salls@cs.ucsb.edu> wrote:
> In the case that compat_get_bitmap fails we do not want to copy the
> bitmap to the user as it will contain uninitialized stack data and
> leak sensitive data.

Ack, looks sane, applied.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
