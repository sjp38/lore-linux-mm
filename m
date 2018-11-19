Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB08F6B17A5
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 20:03:02 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id m1-v6so22160444plb.13
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 17:03:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h188si13219299pfg.44.2018.11.18.17.03.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 18 Nov 2018 17:03:01 -0800 (PST)
Date: Sun, 18 Nov 2018 17:03:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/filemap.c: minor optimization in write_iter file
 operation
Message-ID: <20181119010300.GD7861@bombadil.infradead.org>
References: <1542542538-11938-1-git-send-email-laoar.shao@gmail.com>
 <20181118121318.GC7861@bombadil.infradead.org>
 <CALOAHbAfWkAYJPTRfyPmHKSmg7UEhtnamzUVx9xd4oYkqi_x8g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbAfWkAYJPTRfyPmHKSmg7UEhtnamzUVx9xd4oYkqi_x8g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, darrick.wong@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Nov 18, 2018 at 11:02:19PM +0800, Yafang Shao wrote:
> On Sun, Nov 18, 2018 at 8:13 PM Matthew Wilcox <willy@infradead.org> wrote:
> > Did you check the before/after code generation with this patch applied?
> 
> Yes, I did.
> My oompiler is gcc-4.8.5, a litte old, and with CONFIG_CC_OPTIMIZE_FOR_SIZE on.
> > with gcc 8.2.0, I see no difference, indicating that the compiler already
> > makes this optimisation.
> 
> Could pls. try set CONFIG_CC_OPTIMIZE_FOR_SIZE on and then compare them again ?

Actually it was already on:

# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y

I happened to build it in my build-tiny output tree.
