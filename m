Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id 448306B020E
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 11:27:23 -0400 (EDT)
Received: by mail-bk0-f49.google.com with SMTP id my13so83916bkb.22
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 08:27:21 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id ua6si1087542bkb.106.2014.03.20.08.27.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Mar 2014 08:27:20 -0700 (PDT)
Date: Thu, 20 Mar 2014 15:26:57 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Message-ID: <20140320152657.381956ff@alan.etchedpixels.co.uk>
In-Reply-To: <CANq1E4Ro8bsgp1QS_Qf9KKBAMZH+joMW5DmfyZ4OBJuTxdXCZA@mail.gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<CA+55aFyNORiS2XidhWoDBVyO6foZuPJTg_BOP3aLtvVhY1R6mw@mail.gmail.com>
	<CANq1E4TuiU6_J=N0WoPav=0AxOJ9G1w+FGvO15kmGP76i+-caw@mail.gmail.com>
	<20140320144127.1d411f26@alan.etchedpixels.co.uk>
	<CANq1E4Ro8bsgp1QS_Qf9KKBAMZH+joMW5DmfyZ4OBJuTxdXCZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, Kristian =?UTF-8?B?SMO4Z3NiZXJn?= <krh@bitplanet.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael
 Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Thu, 20 Mar 2014 16:12:54 +0100
David Herrmann <dh.herrmann@gmail.com> wrote:

> Hi
> 
> On Thu, Mar 20, 2014 at 3:41 PM, One Thousand Gnomes
> <gnomes@lxorguk.ukuu.org.uk> wrote:
> > I think you want two things at minimum
> >
> > owner to seal
> > root can always override
> 
> Why should root be allowed to override?

Because root can already override it by say mmapping the kernel memory
and patching. It also tends to be valuable for debugging horrible
problems with complex systems.

Imposing fake restrictions on root just causes annoyance when doing stuff
like debugging but doesn't actually change the security situation.
> 
> I'm fine with F_SET/GET_SEALS. But given you suggested requiring
> MFD_ALLOW_SEALS for sealing, I don't see why we couldn't limit this
> interface entirely to memfd_create().

But if someone does find a non memfd use for it then it's useful not to
have to go "this fnctl for memfd, that fnctl for the other"

Just planning ahead.


> > Whether you want some way to undo a seal without an exclusive reference as
> > the file owner is another question.
> 
> No. You are never allowed to undo a seal but with an exclusive
> reference. This interface was created for situations _without_ any
> trust relationship. So if the owner is allowed to undo seals, the
> interface doesn't make any sense. The only options I see is to not
> allow un-sealing at all (which I'm fine with) or tracking users (which
> is way too much overhead).

Ok - that makes sense

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
