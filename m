Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 833FB8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:22:36 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id m16so2093267pgd.0
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:22:36 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m4si272533pgk.399.2019.01.15.09.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 Jan 2019 09:22:35 -0800 (PST)
Date: Tue, 15 Jan 2019 09:22:34 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: Make CONFIG_FRAME_VECTOR a visible option
Message-ID: <20190115172234.GA991@infradead.org>
References: <20190115164435.8423-1-olof@lixom.net>
 <20190115170510.GA4274@infradead.org>
 <CAOesGMg4hd8z=2FVDTYMiuKzHnobNLnncV37j77BA+gQGg=heg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOesGMg4hd8z=2FVDTYMiuKzHnobNLnncV37j77BA+gQGg=heg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olof Johansson <olof@lixom.net>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Tue, Jan 15, 2019 at 09:17:30AM -0800, Olof Johansson wrote:
> I'd argue it's *more* confusing to expect users to know about and
> enable some random V4L driver to get this exported kernel API included
> or not. Happy to add "If in doubt, say 'n' here" help text, like we do
> for many many other kernel config options.

It is just like any other library function - you get it with a user.

> In this particular case, a module (under early development and not yet
> ready to upstream, but will be) worked with a random distro kernel
> that enables the kitchen sink of drivers, but not with a more slimmed
> down kernel config. Having to enable a driver you'll never use, just
> to enable some generic exported helpers, is just backwards.

Just develop the damn driver in a kernel tree and let people pull
the whole branch like everyone else: problem solved.
