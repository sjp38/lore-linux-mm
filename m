Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 390AE6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:09:32 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k27-v6so22482333wre.23
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:09:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si979205edf.265.2018.04.24.13.09.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 13:09:30 -0700 (PDT)
Date: Tue, 24 Apr 2018 14:09:27 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: vmalloc with GFP_NOFS
Message-ID: <20180424200927.GU17484@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
 <ce42f323-870c-21df-ac27-1bec6aa7e5d1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ce42f323-870c-21df-ac27-1bec6aa7e5d1@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, Richard Weinberger <richard@nod.at>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Tue 24-04-18 20:26:23, Steven Whitehouse wrote:
[...]
> It would be good to fix this, and it has been known as an issue for a long
> time. We might well be able to make use of the new API though. It might be
> as simple as adding the calls when we get & release glocks, but I'd have to
> check the code to be sure,

Yeah, starting with annotating those locking contexts and how document
how their are used in the reclaim is the great first step. This has to
be done per-fs obviously.
-- 
Michal Hocko
SUSE Labs
