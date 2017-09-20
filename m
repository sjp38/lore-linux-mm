Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5FA6B02C1
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 17:21:48 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e9so6475723iod.4
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 14:21:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d205sor78124itg.142.2017.09.20.14.21.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 14:21:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170920205642.GA20023@infradead.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
 <1505940337-79069-15-git-send-email-keescook@chromium.org> <20170920205642.GA20023@infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 20 Sep 2017 14:21:45 -0700
Message-ID: <CAGXu5j+hr0UwB5NsvPSKVVfM6NFHHhnNeUZbuwyTRppSOx9Ucw@mail.gmail.com>
Subject: Re: [PATCH v3 14/31] vxfs: Define usercopy region in vxfs_inode slab cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Wed, Sep 20, 2017 at 1:56 PM, Christoph Hellwig <hch@infradead.org> wrote:
> Hi Kees,
>
> I've only got this single email from you, which on it's own doesn't
> compile and seems to be part of a 31 patch series.
>
> So as-is NAK, doesn't work.
>
> Please make sure to always send every patch in a series to every
> developer you want to include.

This is why I included several other lists on the full CC (am I
unlucky enough to have you not subscribed to any of them?). Adding a
CC for everyone can result in a huge CC list, especially for the
forth-coming 300-patch timer_list series. ;)

Do you want me to resend the full series to you, or would you prefer
something else like a patchwork bundle? (I'll explicitly add you to CC
for any future versions, though.)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
