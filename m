Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D328F6B0428
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:29:46 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v60so32658487wrc.7
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:29:46 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id l126si17478683wmd.3.2017.06.21.10.29.45
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 10:29:45 -0700 (PDT)
Date: Wed, 21 Jun 2017 19:29:28 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 06/11] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
Message-ID: <20170621172928.uxb35qpyksppcqhn@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
 <alpine.DEB.2.20.1706211033340.2328@nanos>
 <CALCETrXkRQDWQH6oZfg4-36i4sgxjhfXmfaatHmmgXKVwtX+qA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrXkRQDWQH6oZfg4-36i4sgxjhfXmfaatHmmgXKVwtX+qA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Wed, Jun 21, 2017 at 09:04:48AM -0700, Andy Lutomirski wrote:
> I'll look at the end of the whole series and see if I can come up with
> something good.

... along with the logic what we flush when, please. I.e., the text in
struct flush_tlb_info.

Thanks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
