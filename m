Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 903BA6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 18:18:49 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v11-v6so23569471wri.13
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 15:18:49 -0700 (PDT)
Received: from lithops.sigma-star.at (lithops.sigma-star.at. [195.201.40.130])
        by mx.google.com with ESMTPS id 35-v6si1947579wrn.274.2018.04.24.15.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 15:18:47 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: Re: vmalloc with GFP_NOFS
Date: Wed, 25 Apr 2018 00:18:40 +0200
Message-ID: <3894056.cxOY6eVYVp@blindfold>
In-Reply-To: <20180424192803.GT17484@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz> <3732370.1623zxSvNg@blindfold> <20180424192803.GT17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

Am Dienstag, 24. April 2018, 21:28:03 CEST schrieb Michal Hocko:
> > Also only for debugging.
> > Getting rid of vmalloc with GFP_NOFS in UBIFS is no big problem.
> > I can prepare a patch.
> 
> Cool!
> 
> Anyway, if UBIFS has some reclaim recursion critical sections in general
> it would be really great to have them documented and that is where the
> scope api is really handy. Just add the scope and document what is the
> recursion issue. This will help people reading the code as well. Ideally
> there shouldn't be any explicit GFP_NOFS in the code.

So in a perfect world a filesystem calls memalloc_nofs_save/restore and
always uses GFP_KERNEL for kmalloc/vmalloc?

Thanks,
//richard
