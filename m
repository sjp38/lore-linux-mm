Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id CE7A982965
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 18:33:20 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id hy4so8920594vcb.33
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 15:33:20 -0700 (PDT)
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
        by mx.google.com with ESMTPS id ya3si22193757vec.105.2014.07.09.15.33.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 15:33:19 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id im17so8732735vcb.25
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 15:33:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1404324218-4743-3-git-send-email-lauraa@codeaurora.org>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
	<1404324218-4743-3-git-send-email-lauraa@codeaurora.org>
Date: Wed, 9 Jul 2014 15:33:19 -0700
Message-ID: <CAOesGMiKBNDmJhiY-yK0uZmG-MnK82=ffNGxqasLKozqgpQQpw@mail.gmail.com>
Subject: Re: [PATCHv4 2/5] lib/genalloc.c: Add genpool range check function
From: Olof Johansson <olof@lixom.net>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jul 2, 2014 at 11:03 AM, Laura Abbott <lauraa@codeaurora.org> wrote:
>
> After allocating an address from a particular genpool,
> there is no good way to verify if that address actually
> belongs to a genpool. Introduce addr_in_gen_pool which
> will return if an address plus size falls completely
> within the genpool range.
>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Reviewed-by: Olof Johansson <olof@lixom.net>

What's the merge path for this code? Part of the arm64 code that needs
it, I presume?


-Olof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
