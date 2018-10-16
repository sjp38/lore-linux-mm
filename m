Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 400646B0003
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 20:04:18 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id p89-v6so21771507pfj.12
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 17:04:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b74-v6sor3337438pfc.12.2018.10.15.17.04.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 17:04:16 -0700 (PDT)
Date: Mon, 15 Oct 2018 17:04:15 -0700 (PDT)
Subject: Re: [PATCH v2 0/6] sparsemem support for RISC-V
In-Reply-To: <20181015175702.9036-1-logang@deltatee.com>
From: Palmer Dabbelt <palmer@sifive.com>
Message-ID: <mhng-fd0541de-3ac1-4772-916d-be6b2d02e63e@palmer-si-x1c4>
Mime-Version: 1.0 (MHng)
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, sbates@raithlin.com, aou@eecs.berkeley.edu, Christoph Hellwig <hch@lst.de>, akpm@linux-foundation.org, Arnd Bergmann <arnd@arndb.de>, logang@deltatee.com

On Mon, 15 Oct 2018 10:56:56 PDT (-0700), logang@deltatee.com wrote:
> This patchset implements sparsemem on RISC-V. The first few patches
> move some code in existing architectures into common helpers
> so they can be used by the new RISC-V implementation. The final
> patch actually adds sparsmem support to RISC-V.
>
> This is the first small step in supporting P2P on RISC-V.

Thanks.  I see less maintainer tags for the parts that touch other ports than I 
would feel comfortable merging.  I'm going to let this sit in my inbox for 
a bit and we'll see if anything collects.

For patch sets I submit that clean up other ports I've attempted to split the 
patch into N patch sets, where:

* One part adds the generic support, which starts out as dead code.
* One part per arch uses the generic support.

This is a bit of a headache, but it at least allows us to get the RISC-V 
version that uses the generic support in quickly while waiting on acks from the 
other arch maintainers.

Like I said, I'll wait a bit and hope people ack.

Thanks!
