Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 09FC16B0007
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 07:45:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n78so12998483pfj.4
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 04:45:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q21-v6si14071132pls.3.2018.04.24.04.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Apr 2018 04:45:30 -0700 (PDT)
Date: Tue, 24 Apr 2018 04:45:17 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5] fs: dax: Adding new return type vm_fault_t
Message-ID: <20180424114517.GC26636@bombadil.infradead.org>
References: <20180423180625.GA16101@jordon-HP-15-Notebook-PC>
 <20180423194917.GF13383@bombadil.infradead.org>
 <CAFqt6zatfzk8PmBN110LD_x8goU+vO4U9TAGaamJ4UqwRm+g_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zatfzk8PmBN110LD_x8goU+vO4U9TAGaamJ4UqwRm+g_g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: jack@suse.cz, Al Viro <viro@zeniv.linux.org.uk>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, kirill.shutemov@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, Apr 24, 2018 at 11:29:39AM +0530, Souptick Joarder wrote:
> On Tue, Apr 24, 2018 at 1:19 AM, Matthew Wilcox <willy@infradead.org> wrote:
> > On Mon, Apr 23, 2018 at 11:36:25PM +0530, Souptick Joarder wrote:
> >> If the insertion of PTE failed because someone else
> >> already added a different entry in the mean time, we
> >> treat that as success as we assume the same entry was
> >> actually inserted.
> >
> > No, Jan said to *make it a comment*.  In the source file.  That's why
> > he formatted it with the /* */.  Not in the changelog.
> Sorry, got confused.
> 
> I think this should be fine -
> 
> +/*
> +If the insertion of PTE failed because someone else
> +already added a different entry in the mean time, we
> +treat that as success as we assume the same entry was
> +actually inserted.
> +*/

Jan literally typed out exactly what you need to insert:

/*
 * If the insertion of PTE failed because someone else already added a
 * different entry in the mean time, we treat that as success as we assume
 * the same entry was actually inserted.
 */

For some reason you've chosen to wrap the lines shorter than Jan had them,
and use a different comment formatting style from the rest of the kernel.
Why?  I'd suggest re-reading Documentation/process/coding-style.rst
