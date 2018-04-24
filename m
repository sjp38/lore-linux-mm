Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADFC6B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 19:09:51 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u56-v6so22798502wrf.18
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:09:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w11si2522173edm.144.2018.04.24.16.09.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 16:09:50 -0700 (PDT)
Date: Tue, 24 Apr 2018 17:09:43 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: vmalloc with GFP_NOFS
Message-ID: <20180424230943.GY17484@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
 <3732370.1623zxSvNg@blindfold>
 <20180424192803.GT17484@dhcp22.suse.cz>
 <3894056.cxOY6eVYVp@blindfold>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3894056.cxOY6eVYVp@blindfold>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Wed 25-04-18 00:18:40, Richard Weinberger wrote:
> Am Dienstag, 24. April 2018, 21:28:03 CEST schrieb Michal Hocko:
> > > Also only for debugging.
> > > Getting rid of vmalloc with GFP_NOFS in UBIFS is no big problem.
> > > I can prepare a patch.
> > 
> > Cool!
> > 
> > Anyway, if UBIFS has some reclaim recursion critical sections in general
> > it would be really great to have them documented and that is where the
> > scope api is really handy. Just add the scope and document what is the
> > recursion issue. This will help people reading the code as well. Ideally
> > there shouldn't be any explicit GFP_NOFS in the code.
> 
> So in a perfect world a filesystem calls memalloc_nofs_save/restore and
> always uses GFP_KERNEL for kmalloc/vmalloc?

Exactly! And in a dream world those memalloc_nofs_save act as a
documentation of the reclaim recursion documentation ;)
-- 
Michal Hocko
SUSE Labs
