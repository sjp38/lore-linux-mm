Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id F2D646B0038
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:30:11 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so10939313igb.5
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 06:30:11 -0800 (PST)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com. [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id n9si8086091ige.49.2015.01.19.06.30.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 06:30:10 -0800 (PST)
Received: by mail-ie0-f181.google.com with SMTP id vy18so8437336iec.12
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 06:30:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54BCC153.5060804@gmail.com>
References: <54AFCE4A.80804@gmail.com>
	<CANq1E4ScALBHtN5B_1N0ynKFx4HwZaQZNg3RAv4tcn10YLHtAA@mail.gmail.com>
	<54BCC153.5060804@gmail.com>
Date: Mon, 19 Jan 2015 15:30:10 +0100
Message-ID: <CANq1E4TATDWEZDbDk85BN6kQw8ZSiZJ_eSubUaFTkhQm8URMcA@mail.gmail.com>
Subject: Re: File sealing man pages for review (memfd_create(2), fcntl(2))
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: "linux-man@vger.kernel.org" <linux-man@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Lennart Poettering <lennart@poettering.net>, Andy Lutomirski <luto@amacapital.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Florian Weimer <fweimer@redhat.com>, John Stultz <john.stultz@linaro.org>, Carlos O'Donell <carlos@systemhalted.org>

Hi

On Mon, Jan 19, 2015 at 9:33 AM, Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> [...]
>
> By the way, I forgot to say that I also added this error under ERRORS:
>
> [[
> .TP
> .B EINVAL
> .I cmd
> is
> .BR F_ADD_SEALS
> and
> .I arg
> includes an unrecognized sealing bit or
> the filesystem containing the inode referred to by
> .I fd
> does not support sealing.
> ]]
>
> Look okay?

I thought I already mentioned that somewhere.. eh, seems I didn't :) Looks good!

>> Both man-pages look really good. Thanks a lot!
>
> You're welcome. Thanks for the initial drafts, and this review.
> The changes will go out with the next man-pages release.

Perfect! Thanks Michael!
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
