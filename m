Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0EEE76B4E9C
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 14:40:15 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 4so27020213plc.5
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 11:40:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d188sor11337253pfg.59.2018.11.28.11.40.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 11:40:13 -0800 (PST)
Date: Wed, 28 Nov 2018 11:40:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 07/10] mm/khugepaged: minor reorderings in
 collapse_shmem()
In-Reply-To: <20181128105911.ggngeqq5xevxpmsk@kshutemo-mobl1>
Message-ID: <alpine.LSU.2.11.1811281128030.5027@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils> <alpine.LSU.2.11.1811261526400.2275@eggly.anvils> <20181127075945.m5nbflc6nqto6f2i@kshutemo-mobl1> <alpine.LSU.2.11.1811271121410.4027@eggly.anvils>
 <20181128105911.ggngeqq5xevxpmsk@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

On Wed, 28 Nov 2018, Kirill A. Shutemov wrote:
> On Tue, Nov 27, 2018 at 12:23:32PM -0800, Hugh Dickins wrote:
> 
> > Actually, I think we could VM_BUG_ON(page_mapping(page) != mapping),
> > couldn't we? Not that I propose to make such a change at this stage.
> 
> Yeah it should be safe. We may put WARN there.

Later yes, but for now I'm leaving the patch unchanged -
been burnt before by last minute changes that didn't turn out so well!

> Agreed on all fronts. Sorry for the noise.

No problem at all: it's important that you challenge what looked wrong.
This time around, I was the one with the advantage of recent familiarity.

> 
> > > The rest of the patch *looks* okay, but I found it hard to follow.
> > > Splitting it up would make it easier.
> > 
> > It needs some time, I admit: thanks a lot for persisting with it.
> > And thanks (to you and to Matthew) for the speedy Acks elsewhere.
> > 
> > Hugh
> 
> -- 
>  Kirill A. Shutemov

Thanks again,
Hugh
