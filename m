Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8B66B0069
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 16:07:54 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d65so19450561ith.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 13:07:54 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id p203si5018261oia.190.2016.08.19.13.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 13:07:53 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id b22so6961174oii.3
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 13:07:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJi4qMD5p38i5NuR7fh38m7mp+7qZNXgUiGNRTaLtYoxA@mail.gmail.com>
References: <20160817222921.GA25148@www.outflux.net> <CA+55aFyiAOSM=ubzfOtdMx6e6vAmDS4JYW4sUU-5sQKPPzWBdQ@mail.gmail.com>
 <CAGXu5jJi4qMD5p38i5NuR7fh38m7mp+7qZNXgUiGNRTaLtYoxA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 19 Aug 2016 13:07:53 -0700
Message-ID: <CA+55aFwVhy59d0OH1En_Z7agsQAkW41QoOXAptr9eQt25VMRNQ@mail.gmail.com>
Subject: Re: [PATCH] usercopy: Skip multi-page bounds checking on SLOB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Rik van Riel <riel@redhat.com>, Laura Abbott <labbott@fedoraproject.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kernel test robot <xiaolong.ye@intel.com>

On Fri, Aug 19, 2016 at 1:03 PM, Kees Cook <keescook@chromium.org> wrote:
>
> Okay, I can live with that. I'd hoped to keep the general split
> between the other checks (i.e. stack) and the allocator, but if this
> is preferred, that's cool. :)

If it had been anything else than SLOB, I might have cared. As it was,
I didn't think it was worth worrying about SLOB together with
hardening.

It was also about the __check_object_size() modification just being
very ugly, with a "return NULL" in the middle of the function. I
looked at just splitting that function up, and having a part of it
that would just go away when the slab allocator wasn't smart enough,
but that would have been a bigger change that I'm not interested in
taking right now. So it could be a future improvement, and maybe we
could then re-instate SLOB with partial checking.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
