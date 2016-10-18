Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 04C636B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 10:20:12 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id x23so12931602lfi.0
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 07:20:11 -0700 (PDT)
Received: from mail-lf0-f65.google.com (mail-lf0-f65.google.com. [209.85.215.65])
        by mx.google.com with ESMTPS id i132si820035lfd.290.2016.10.18.07.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 07:20:10 -0700 (PDT)
Received: by mail-lf0-f65.google.com with SMTP id x79so33003251lff.2
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 07:20:09 -0700 (PDT)
Date: Tue, 18 Oct 2016 16:20:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161018142007.GL12092@dhcp22.suse.cz>
References: <20161017121809.189039-1-kirill.shutemov@linux.intel.com>
 <20161017123021.rlyz44dsf4l4xnve@black.fi.intel.com>
 <20161017141245.GC27459@dhcp22.suse.cz>
 <20161017145539.GA26930@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161017145539.GA26930@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 17-10-16 17:55:40, Kirill A. Shutemov wrote:
> On Mon, Oct 17, 2016 at 04:12:46PM +0200, Michal Hocko wrote:
> > On Mon 17-10-16 15:30:21, Kirill A. Shutemov wrote:
[...]
> > > We add two handle to specify minimal file size for huge pages:
> > > 
> > >   - mount option 'huge_min_size';
> > > 
> > >   - sysfs file /sys/kernel/mm/transparent_hugepage/shmem_min_size for
> > >     in-kernel tmpfs mountpoint;
> > 
> > Could you explain who might like to change the minimum value (other than
> > disable the feautre for the mount point) and for what reason?
> 
> Depending on how well CPU microarchitecture deals with huge pages, you
> might need to set it higher in order to balance out overhead with benefit
> of huge pages.

I am not sure this is a good argument. How do a user know and what will
help to make that decision? Why we cannot autotune that? In other words,
adding new knobs just in case turned out to be a bad idea in the past.

> In other case, if it's known in advance that specific mount would be
> populated with large files, you might want to set it to zero to get huge
> pages allocated from the beginning.

Cannot we use [mf]advise for that purpose?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
