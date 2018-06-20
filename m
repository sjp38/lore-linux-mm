Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B63156B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 13:27:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e22-v6so112414pga.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 10:27:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l33-v6si2753343pld.514.2018.06.20.10.27.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Jun 2018 10:27:33 -0700 (PDT)
Date: Wed, 20 Jun 2018 10:27:25 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] include: dax: new-return-type-vm_fault_t
Message-ID: <20180620172725.GA31068@bombadil.infradead.org>
References: <20180620172046.GA27894@jordon-HP-15-Notebook-PC>
 <CAFqt6zYyE+Bm90CckQvJwfW85Hj2SN-Z6J6DidpgHu3h98Sgfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zYyE+Bm90CckQvJwfW85Hj2SN-Z6J6DidpgHu3h98Sgfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Jun 20, 2018 at 10:51:49PM +0530, Souptick Joarder wrote:
> On Wed, Jun 20, 2018 at 10:50 PM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> > Use new return type vm_fault_t for fault handler. For now,
> > this is just documenting that the function returns a VM_FAULT
> > value rather than an errno. Once all instances are converted,
> > vm_fault_t will become a distinct type.

> As part of
> commit ab77dab46210 ("fs/dax.c: use new return type vm_fault_t")
> I missed this change which leads to compilation error.
> Sorry about it.
> 
> This patch need to be in 4.18-rc-2/x on priority.

It only leads to a compilation error for you; the rest of us are still
using typedef int vm_fault_t, so it's not a mismatch.  It'd be nice to get
this fixed, but it's not a priority.

Sorry I didn't spot this during my review.
