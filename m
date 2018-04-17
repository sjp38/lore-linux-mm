Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C12B6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 20:19:13 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o2-v6so3408497plk.0
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 17:19:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k7si10639772pgq.286.2018.04.16.17.19.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Apr 2018 17:19:11 -0700 (PDT)
Date: Mon, 16 Apr 2018 17:19:07 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] dax: Change return type to vm_fault_t
Message-ID: <20180417001907.GB25048@bombadil.infradead.org>
References: <20180414155059.GA18015@jordon-HP-15-Notebook-PC>
 <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com>
 <20180417001421.GH22870@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417001421.GH22870@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Dan Williams <dan.j.williams@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Mon, Apr 16, 2018 at 08:14:22PM -0400, Theodore Y. Ts'o wrote:
> On Mon, Apr 16, 2018 at 09:14:48AM -0700, Dan Williams wrote:
> > Ugh, so this change to vmf_insert_mixed() went upstream without fixing
> > the users? This changelog is now misleading as it does not mention
> > that is now an urgent standalone fix. On first read I assumed this was
> > part of a wider effort for 4.18.
> 
> Why is this an urgent fix?  I thought all the return type change was
> did something completely innocuous that would not cause any real
> difference.

Keep reading the thread; Dan is mistaken.
