Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23E7F8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:29:38 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id p4so4694400pgj.21
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 12:29:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t74si4892767pgc.150.2018.12.14.12.29.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 14 Dec 2018 12:29:36 -0800 (PST)
Date: Fri, 14 Dec 2018 12:29:27 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181214202927.GI10600@bombadil.infradead.org>
References: <20181212215931.GG5037@redhat.com>
 <20181213005119.GD29416@dastard>
 <05a68829-6e6d-b766-11b4-99e1ba4bc87b@nvidia.com>
 <CAPcyv4jyG3YTtghyr04wws_hcSBAmPBpnCm0tFcKgz9VwrV=ow@mail.gmail.com>
 <01cf4e0c-b2d6-225a-3ee9-ef0f7e53684d@nvidia.com>
 <CAPcyv4hrbA9H20bi+QMpKNi7r=egstt61MdQSD5Fb293W1btaw@mail.gmail.com>
 <20181214194843.GG10600@bombadil.infradead.org>
 <ed49a260-ffd5-613d-e48b-dfb4b550e8bb@intel.com>
 <20181214200311.GH10600@bombadil.infradead.org>
 <CAPcyv4j1CJO=TAXiNzp032GnkJ0JcYSEXkn1ZqVP2o3b=P453g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4j1CJO=TAXiNzp032GnkJ0JcYSEXkn1ZqVP2o3b=P453g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, John Hubbard <jhubbard@nvidia.com>, david <david@fromorbit.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Dec 14, 2018 at 12:17:08PM -0800, Dan Williams wrote:
> On Fri, Dec 14, 2018 at 12:03 PM Matthew Wilcox <willy@infradead.org> wrote:
> > Yes; working on the pfn-to-page structure right now as it happens ...
> > in the meantime, an XArray for it probably wouldn't be _too_ bad.
> 
> It might... see the recent patch from Ketih responding to complaints
> about get_dev_pagemap() lookup overhead:

Yeah, I saw.  I called xa_dump() on the pgmap_array() running under
QEmu and it's truly awful because the NVDIMMs presented by QEmu are
very misaligned.  If we can make the NVDIMMs better aligned, we won't
hit such a bad case in the XArray data structure.
