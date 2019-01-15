Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3B5B8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:17:42 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id f24so2490027ioh.21
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:17:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x16sor2000402iol.120.2019.01.15.09.17.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 09:17:41 -0800 (PST)
MIME-Version: 1.0
References: <20190115164435.8423-1-olof@lixom.net> <20190115170510.GA4274@infradead.org>
In-Reply-To: <20190115170510.GA4274@infradead.org>
From: Olof Johansson <olof@lixom.net>
Date: Tue, 15 Jan 2019 09:17:30 -0800
Message-ID: <CAOesGMg4hd8z=2FVDTYMiuKzHnobNLnncV37j77BA+gQGg=heg@mail.gmail.com>
Subject: Re: [PATCH] mm: Make CONFIG_FRAME_VECTOR a visible option
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Tue, Jan 15, 2019 at 9:05 AM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Tue, Jan 15, 2019 at 08:44:35AM -0800, Olof Johansson wrote:
> > CONFIG_FRAME_VECTOR was made an option to avoid including the bloat on
> > platforms that try to keep footprint down, which makes sense.
> >
> > The problem with this is external modules that aren't built in-tree.
> > Since they don't have in-tree Kconfig, whether they can be loaded now
> > depends on whether your kernel config enabled some completely unrelated
> > driver that happened to select it. That's a weird and unpredictable
> > situation, and makes for some awkward requirements for the standalone
> > modules.
> >
> > For these reasons, give someone the option to manually enable this when
> > configuring the kernel.
>
> NAK, we should not confuse kernel users for stuff that is out of tree.

I'd argue it's *more* confusing to expect users to know about and
enable some random V4L driver to get this exported kernel API included
or not. Happy to add "If in doubt, say 'n' here" help text, like we do
for many many other kernel config options.

In this particular case, a module (under early development and not yet
ready to upstream, but will be) worked with a random distro kernel
that enables the kitchen sink of drivers, but not with a more slimmed
down kernel config. Having to enable a driver you'll never use, just
to enable some generic exported helpers, is just backwards.


-Olof
