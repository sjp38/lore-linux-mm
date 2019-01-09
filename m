Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0498E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:37:57 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id p65-v6so1961572ljb.16
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:37:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 142sor14010047lfz.23.2019.01.09.08.37.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 08:37:55 -0800 (PST)
MIME-Version: 1.0
References: <20190109161916.GA23410@jordon-HP-15-Notebook-PC> <20190109162332.GL6310@bombadil.infradead.org>
In-Reply-To: <20190109162332.GL6310@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 9 Jan 2019 22:11:46 +0530
Message-ID: <CAFqt6zYQU+jN57Lh2Enx-t9EKHSjSKibUHU1Y-KyzAzxWVy3Qw@mail.gmail.com>
Subject: Re: [PATCH] include/linux/hmm.h: Convert to use vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, jglisse@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>

On Wed, Jan 9, 2019 at 9:53 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, Jan 09, 2019 at 09:49:17PM +0530, Souptick Joarder wrote:
> > convert to use vm_fault_t type as return type for
> > fault handler.
>
> I think you'll also need to convert hmm_devmem_fault().  And that's
> going to lead to some more spots.

I will add it in v2.
>
> (It's important to note that this is the patch working as designed.  It's
> throwing up warnings where code *hasn't* been converted to vm_fault_t yet
> but should have been).

Ok.
