Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 98E486B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 11:50:12 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id s8so595962pgf.16
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:50:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e92-v6si7616479plb.82.2018.02.21.08.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Feb 2018 08:50:11 -0800 (PST)
Date: Wed, 21 Feb 2018 08:50:06 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Use higher-order pages in vmalloc
Message-ID: <20180221165006.GA27687@bombadil.infradead.org>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
 <151670493255.658225.2881484505285363395.stgit@buzz>
 <20180221154214.GA4167@bombadil.infradead.org>
 <CALCETrU5jaennr5ziS9NzNA6KpK204acdroJpuc6yYy3PGvpHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrU5jaennr5ziS9NzNA6KpK204acdroJpuc6yYy3PGvpHQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Dave Hansen <dave.hansen@intel.com>, LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, Feb 21, 2018 at 04:11:16PM +0000, Andy Lutomirski wrote:
> On Wed, Feb 21, 2018 at 3:42 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > +++ b/kernel/fork.c
> > @@ -319,12 +319,12 @@ static void account_kernel_stack(struct task_struct *tsk, int account)
> >         if (vm) {
> >                 int i;
> >
> > -               BUG_ON(vm->nr_pages != THREAD_SIZE / PAGE_SIZE);
...
> > +               if (j) {
> > +                       area->nr_pages -= (1UL << j) - 1;
> 
> Is there any code that expects area->nr_pages to be the size of the
> area in pages?  I don't know of any such code.

I found one and deleted it ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
