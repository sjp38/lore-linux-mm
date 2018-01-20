Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF3A36B0033
	for <linux-mm@kvack.org>; Sat, 20 Jan 2018 04:38:15 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k13so2929434wrd.7
        for <linux-mm@kvack.org>; Sat, 20 Jan 2018 01:38:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x17sor4911938edx.14.2018.01.20.01.38.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Jan 2018 01:38:14 -0800 (PST)
Date: Sat, 20 Jan 2018 10:38:10 +0100
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180120093808.7mol6d7jkngy22ky@ltop.local>
References: <20180118145830.GA6406@redhat.com>
 <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
 <CA+55aFy43ypm0QvA5SqNR4O0ZJETbkR3NDR=dnSdvejc_nmSJQ@mail.gmail.com>
 <20180118234955.nlo55rw2qsfnavfm@node.shutemov.name>
 <20180119125503.GA2897@bombadil.infradead.org>
 <CA+55aFwWCeFrhN+WJDD8u9nqBzmvknXk428Q0dVwwXAvwhg_-w@mail.gmail.com>
 <20180119221243.GL13338@ZenIV.linux.org.uk>
 <CA+55aFw4mw32Mu0_+cgKAzxCNvDW1VPcESv7CyajexfDfMju1A@mail.gmail.com>
 <20180120020237.GM13338@ZenIV.linux.org.uk>
 <20180120052432.GN13338@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180120052432.GN13338@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, sparse mailing list <linux-sparse@vger.kernel.org>

On Sat, Jan 20, 2018 at 05:24:32AM +0000, Al Viro wrote:
> On Sat, Jan 20, 2018 at 02:02:37AM +0000, Al Viro wrote:
> 
> > Note that those sizes are rather sensitive to lockdep, spinlock debugging, etc.
> 
> That they certainly are: on one of the testing .config I'm using it gave this:
>    1104 sizeof struct page = 56

Yes, I get this already with defconfig.
It's a problem with sparse which ignore the alignment attribute
(in fact all 'trailing' attributes in type declarations).

I'm looking to fix it.

-- Luc Van Oostenryck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
