Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6B06490001E
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 22:36:17 -0400 (EDT)
Received: by pabrd3 with SMTP id rd3so43878470pab.6
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 19:36:17 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id n10si34148405pap.21.2015.03.09.19.36.15
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 19:36:16 -0700 (PDT)
Message-ID: <54FE589C.1050705@linux.intel.com>
Date: Mon, 09 Mar 2015 19:36:12 -0700
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to non-privileged
 userspace
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name> <CAGXu5jLvHa0fAV9sBwW5AvzkJY1AvQyhBmrRHLZWAtw5=-9aZg@mail.gmail.com> <CALCETrU_3FS6B7LtkAwdC3e8xfiwdhPjkVWPgxP1Vy2uPeqMtA@mail.gmail.com>
In-Reply-To: <CALCETrU_3FS6B7LtkAwdC3e8xfiwdhPjkVWPgxP1Vy2uPeqMtA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@chromium.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Mark Seaborn <mseaborn@chromium.org>

On 03/09/2015 05:19 PM, Andy Lutomirski wrote:
> per-pidns like this is no good.  You shouldn't be able to create a
> non-paranoid pidns if your parent is paranoid.

That sounds like a reasonable addition that shouldn't be hard to add.

> Also, at some point we need actual per-ns controls.  This mount option
> stuff is hideous.

So,

	per-pidns == bad
	per-ns == good

If the pid namespace is the wrong place, which namespace is the right place?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
