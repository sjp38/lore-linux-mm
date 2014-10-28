Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 18184900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 15:56:18 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id rl12so1484958iec.31
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 12:56:17 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id fd9si3849759icb.37.2014.10.28.12.56.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 12:56:16 -0700 (PDT)
Received: by mail-ie0-f173.google.com with SMTP id tr6so1495222ieb.32
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 12:56:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141028184719.GB29098@hydra.tuxags.com>
References: <20140927183403.13738.22121.stgit@zurg>
	<20140927191515.13738.18027.stgit@zurg>
	<20141028184719.GB29098@hydra.tuxags.com>
Date: Tue, 28 Oct 2014 23:56:15 +0400
Message-ID: <CALYGNiOrNfxbCJggraxgiFOdvn3jki_751cpssi+p_eST0Wdgg@mail.gmail.com>
Subject: Re: [PATCH v3 1/4] mm/balloon_compaction: redesign ballooned pages management
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Rafael Aquini <aquini@redhat.com>, Stable <stable@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>

On Tue, Oct 28, 2014 at 9:47 PM, Matt Mullins <mmullins@mmlx.us> wrote:
> On Sat, Sep 27, 2014 at 11:15:16PM +0400, Konstantin Khlebnikov wrote:
>> This patch fixes all of them.
>
> It seems to have rendered virtio_balloon completely ineffective without
> CONFIG_COMPACTION and CONFIG_BALLOON_COMPACTION, even for the case that I'm
> expanding the memory available to my VM.

What do you mean by ineffective?

That it cannot handle fragmentation? I saw that without compaction
ballooning works even better:
it allocates pages without GFP_MOVABLE and buddy allocator returns
much less scattered pages.

>
> Was this intended?  Should Kconfig be updated so that VIRTIO_BALLOON depends on
> BALLOON_COMPACTION now?

Nope, this is independent feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
