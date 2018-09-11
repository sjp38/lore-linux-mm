Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1FB8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 14:20:47 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u126-v6so12381073itb.0
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 11:20:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q11-v6sor11752857iop.216.2018.09.11.11.20.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 11:20:45 -0700 (PDT)
MIME-Version: 1.0
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee>
 <20180830205527.dmemjwxfbwvkdzk2@suse.de> <alpine.LRH.2.21.1808310711380.17865@math.ut.ee>
 <20180831070722.wnulbbmillxkw7ke@suse.de> <alpine.DEB.2.21.1809081223450.1402@nanos.tec.linutronix.de>
 <20180911114927.gikd3uf3otxn2ekq@suse.de>
In-Reply-To: <20180911114927.gikd3uf3otxn2ekq@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 11 Sep 2018 08:20:33 -1000
Message-ID: <CA+55aFzo3b2aChbJ2aOSvKbguYKMG8wv02NS8qzp6w2T5z8WTg@mail.gmail.com>
Subject: Re: 32-bit PTI with THP = userspace corruption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Meelis Roos <mroos@linux.ee>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Sep 11, 2018 at 1:49 AM Joerg Roedel <jroedel@suse.de> wrote:
>
> I had a look into the THP and the HugeTLBfs code, and that is not
> really easy to fix there. As I can see it now, there are a few options
> to fix that, but most of them are ugly:

Just do (4): disable PTI with PAE.

Then we can try to make people perhaps not use !PAE very much, and
warn if you have PAE disabled on a machine that supports it.

As you say, there shouldn't be much of a performance impact from PAE.
There is a more noticeable performance impact from HIGHMEM, not from
HIGHMEM_64G, iirc.

                Linus
