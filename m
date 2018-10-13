Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 487D86B026F
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 21:44:33 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z12-v6so13607423pfl.17
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 18:44:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7-v6sor2764405pfr.53.2018.10.12.18.44.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 18:44:32 -0700 (PDT)
Date: Fri, 12 Oct 2018 18:44:29 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v2 2/2] mm: speed up mremap by 500x on large regions
Message-ID: <20181013014429.GB207108@joelaf.mtv.corp.google.com>
References: <20181012013756.11285-2-joel@joelfernandes.org>
 <20181012113056.gxhcbrqyu7k7xnyv@kshutemo-mobl1>
 <20181012125046.GA170912@joelaf.mtv.corp.google.com>
 <20181012.111836.1569129998592378186.davem@davemloft.net>
 <20181013013540.GA207108@joelaf.mtv.corp.google.com>
 <CAKOZueuNvWvn18vffJWpbpg7h-uScT8gXrrudTB2pnT4M2HJ_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZueuNvWvn18vffJWpbpg7h-uScT8gXrrudTB2pnT4M2HJ_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: David Miller <davem@davemloft.net>, kirill@shutemov.name, linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@android.com, Minchan Kim <minchan@kernel.org>, Ramon Pantin <pantin@google.com>, hughd@google.com, Lokesh Gidra <lokeshgidra@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, aryabinin@virtuozzo.com, luto@kernel.org, bp@alien8.de, catalin.marinas@arm.com, chris@zankel.net, dave.hansen@linux.intel.com, elfring@users.sourceforge.net, fenghua.yu@intel.com, geert@linux-m68k.org, gxt@pku.edu.cn, deller@gmx.de, mingo@redhat.com, jejb@parisc-linux.org, jdike@addtoit.com, jonas@southpole.se, Julia.Lawall@lip6.fr, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, lftan@altera.com, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm <linux-mm@kvack.org>, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, jcmvbkbc@gmail.com, nios2-dev@lists.rocketboards.org, Peter Zijlstra <peterz@infradead.org>, richard@nod.at

On Fri, Oct 12, 2018 at 06:39:45PM -0700, Daniel Colascione wrote:
> Not 32-bit ARM?

Well, I didn't want to enable every possible architecture we could in a
single go. Certainly arm32 can be a follow on enablement as can be other
architectures. The point of this series is to upstream this feature and
enable a hand-picked few architectures as a first step.

thanks,

 - Joel
