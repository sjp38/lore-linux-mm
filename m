Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 580546B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 13:06:28 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id az10so2809834plb.11
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 10:06:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g10-v6sor14049599pfg.54.2018.11.14.10.06.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 10:06:26 -0800 (PST)
Date: Wed, 14 Nov 2018 10:06:24 -0800 (PST)
Subject: Re: [PATCH v2 0/2] Introduce common code for risc-v sparsemem support
In-Reply-To: <20181107205433.3875-1-logang@deltatee.com>
From: Palmer Dabbelt <palmer@sifive.com>
Message-ID: <mhng-dfc065e5-80c6-4a9d-b95b-95170df42969@palmer-si-x1c4>
Mime-Version: 1.0 (MHng)
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, sbates@raithlin.com, aou@eecs.berkeley.edu, Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, logang@deltatee.com

On Wed, 07 Nov 2018 12:54:31 PST (-0800), logang@deltatee.com wrote:
> These are the first two common patches in my series to introduce
> sparsemem support to RISC-V. The full series was posted last cycle
> here [1] and the latest version can be found here [2].
>
> As recommended by Palmer, I'd like to get the changes to common code
> merged and then I will pursue the cleanups in the individual arches (arm,
> arm64, and sh) as well as add the new feature to riscv.
>
> I would suggest we merge these two patches through Andrew's mm tree.

I haven't seen any review on this.  It looks fine to me, but I'm not qualified 
to review it as I don't really know anything about core MM stuff -- and I 
certainly don't feel comfortable taking this through my tree.

I've To'd linux-mm, hopefully it just got lost in the shuffle during the merge 
window.
