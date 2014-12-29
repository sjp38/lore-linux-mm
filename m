Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id EDF3E6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 05:40:43 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id x13so740845wgg.26
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 02:40:43 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id bc4si58068973wib.2.2014.12.29.02.40.42
        for <linux-mm@kvack.org>;
        Mon, 29 Dec 2014 02:40:43 -0800 (PST)
Date: Mon, 29 Dec 2014 12:37:57 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 30/38] s390: drop pte_file()-related helpers
Message-ID: <20141229103757.GA379@node.dhcp.inet.fi>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1419423766-114457-31-git-send-email-kirill.shutemov@linux.intel.com>
 <20141229110727.75afa56d@mschwide>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141229110727.75afa56d@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>

On Mon, Dec 29, 2014 at 11:07:27AM +0100, Martin Schwidefsky wrote:
> On Wed, 24 Dec 2014 14:22:38 +0200
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > We've replaced remap_file_pages(2) implementation with emulation.
> > Nobody creates non-linear mapping anymore.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > ---
> > @@ -279,7 +279,6 @@ static inline int is_module_addr(void *addr)
> >   *
> >   * pte_present is true for the bit pattern .xx...xxxxx1, (pte & 0x001) == 0x001
> >   * pte_none    is true for the bit pattern .10...xxxx00, (pte & 0x603) == 0x400
> > - * pte_file    is true for the bit pattern .11...xxxxx0, (pte & 0x601) == 0x600
> >   * pte_swap    is true for the bit pattern .10...xxxx10, (pte & 0x603) == 0x402
> >   */
>  
> Nice, once this is upstream I can free up one of the software bits in
> the pte by redefining the type bits. Right now all of them are used up.
> Is the removal of non-linear mappings a done deal ?

Yes, if no horrible regression will be reported. We don't create
non-linear mapping in -mm (and -next) tree for a few release cycles.
Nobody complained so far.

Ack?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
