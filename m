Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E5C206B0007
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 02:33:41 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id 88-v6so2234288wrp.21
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 23:33:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 63-v6sor9649979wmr.25.2018.10.09.23.33.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 23:33:40 -0700 (PDT)
Date: Wed, 10 Oct 2018 08:33:36 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 0/3] mm: Fix for movable_node boot option
Message-ID: <20181010063336.GA57677@gmail.com>
References: <20181002143821.5112-1-msys.mizuma@gmail.com>
 <20181009151433.p5aqcyrzrv7gfpyh@gabell>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009151433.p5aqcyrzrv7gfpyh@gabell>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org


* Masayoshi Mizuma <msys.mizuma@gmail.com> wrote:

> Ping...
>
> >  arch/x86/kernel/e820.c   | 15 +++--------
> >  include/linux/memblock.h | 15 -----------
> >  mm/page_alloc.c          | 54 +++++++++++++++++++++++++++-------------
> >  3 files changed, 40 insertions(+), 44 deletions(-)

If the problem is fixed then the e820 revert looks good to me:

Acked-by: Ingo Molnar <mingo@kernel.org>

The other patches need review and acks from MM folks, and the series (assuming all patches are 
fine - I only looked at the e820 one) is -mm material I suppose?

Thanks,

	Ingo
