Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 73C456B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:53:17 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so9334235pab.20
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:53:17 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so9390109pab.38
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:53:14 -0700 (PDT)
Message-ID: <525D8106.9020304@zankel.net>
Date: Tue, 15 Oct 2013 10:53:10 -0700
From: Chris Zankel <chris@zankel.net>
MIME-Version: 1.0
Subject: Re: CONFIG_SLUB/USE_SPLIT_PTLOCKS compatibility
References: <CAMo8BfKqWPbDCMwCoH6BO6uXyYwr0Z1=AaMJDRLQt66FLb7LAg@mail.gmail.com> <20131014071205.GA23735@shutemov.name> <CAMo8Bf+9+_S0HeOUWjd3AXgsuM-XWYZx8b6aL=2+AFt0EK9DKg@mail.gmail.com>
In-Reply-To: <CAMo8Bf+9+_S0HeOUWjd3AXgsuM-XWYZx8b6aL=2+AFt0EK9DKg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "David S. Miller" <davem@davemloft.net>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>

On 10/14/2013 04:49 AM, Max Filippov wrote:
> Buddy allocator was used here prior to commit 6656920 [XTENSA] Add
> support for cache-aliasing I can only guess that the change was made
> to make allocated page tables have the same colour, but am not sure
> why this is needed. Chris? 
Max, I think you are right that in an earlier attempt to support cache
aliasing, we tried to allocate pages with the correct 'color', and
cached pages locally (if I remember correctly). The approach we use now
doesn't require that so the suggested patches are fine. (Note that cache
aliasing support hasn't been committed to mainline yet)

Thanks,
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
