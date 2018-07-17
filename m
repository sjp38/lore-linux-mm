Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 644CB6B000A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:49:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b25-v6so529142eds.17
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 05:49:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w44-v6si789513edb.165.2018.07.17.05.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 05:49:31 -0700 (PDT)
Date: Tue, 17 Jul 2018 14:49:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: vmalloc with GFP_NOFS
Message-ID: <20180717124930.GB30926@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
 <20180424183536.GF30619@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424183536.GF30619@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, Richard Weinberger <richard@nod.at>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Tue 24-04-18 14:35:36, Theodore Ts'o wrote:
> On Tue, Apr 24, 2018 at 10:27:12AM -0600, Michal Hocko wrote:
> > fs/ext4/xattr.c
> > 
> > What to do about this? Well, there are two things. Firstly, it would be
> > really great to double check whether the GFP_NOFS is really needed. I
> > cannot judge that because I am not familiar with the code.
> 
> *Most* of the time it's not needed, but there are times when it is.
> We could be more smart about sending down GFP_NOFS only when it is
> needed.  If we are sending too many GFP_NOFS's allocations such that
> it's causing heartburn, we could fix this.  (xattr commands are rare
> enough that I dind't think it was worth it to modulate the GFP flags
> for this particular case, but we could make it be smarter if it would
> help.)

There still seem to be ext4_kvmalloc(NOFS) callers in the ext4 code. Do
you have any plans to get rid of those?
-- 
Michal Hocko
SUSE Labs
