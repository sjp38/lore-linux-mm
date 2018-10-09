Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id D04096B0007
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 11:14:46 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id c6-v6so708473ybm.10
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 08:14:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j18-v6sor2880363ywm.179.2018.10.09.08.14.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 08:14:45 -0700 (PDT)
Date: Tue, 9 Oct 2018 11:14:35 -0400
From: Masayoshi Mizuma <msys.mizuma@gmail.com>
Subject: Re: [PATCH v3 0/3] mm: Fix for movable_node boot option
Message-ID: <20181009151433.p5aqcyrzrv7gfpyh@gabell>
References: <20181002143821.5112-1-msys.mizuma@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002143821.5112-1-msys.mizuma@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org

Ping...

On Tue, Oct 02, 2018 at 10:38:18AM -0400, Masayoshi Mizuma wrote:
> This patch series are the fix for movable_node boot option
> issue which was introduced by commit 124049decbb1 ("x86/e820:
> put !E820_TYPE_RAM regions into memblock.reserved").
> 
> The commit breaks the option because it changed the memory
> gap range to reserved memblock. So, the node is marked as
> Normal zone even if the SRAT has Hot pluggable affinity.
> 
> First and second patch fix the original issue which the commit
> tried to fix, then revert the commit.
> 
> Changelog from v2:
>  - Change the patch order. The revert patch is moved to the last.
> 
> Masayoshi Mizuma (1):
>   Revert "x86/e820: put !E820_TYPE_RAM regions into memblock.reserved"
> 
> Naoya Horiguchi (1):
>   mm: zero remaining unavailable struct pages
> 
> Pavel Tatashin (1):
>   mm: return zero_resv_unavail optimization
> 
>  arch/x86/kernel/e820.c   | 15 +++--------
>  include/linux/memblock.h | 15 -----------
>  mm/page_alloc.c          | 54 +++++++++++++++++++++++++++-------------
>  3 files changed, 40 insertions(+), 44 deletions(-)
> 
> -- 
> 2.18.0
> 
