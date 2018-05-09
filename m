Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 555726B058F
	for <linux-mm@kvack.org>; Wed,  9 May 2018 17:06:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x2-v6so144452wmc.3
        for <linux-mm@kvack.org>; Wed, 09 May 2018 14:06:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a12-v6si441921edq.6.2018.05.09.14.06.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 14:06:19 -0700 (PDT)
Date: Wed, 9 May 2018 23:06:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: vmalloc with GFP_NOFS
Message-ID: <20180509210617.GY32366@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
 <20180424183536.GF30619@thunk.org>
 <20180424192542.GS17484@dhcp22.suse.cz>
 <20180509134222.GU32366@dhcp22.suse.cz>
 <20180509151351.GA4111@magnolia>
 <20180509162451.GA5303@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509162451.GA5303@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, Richard Weinberger <richard@nod.at>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Wed 09-05-18 19:24:51, Mike Rapoport wrote:
> On Wed, May 09, 2018 at 08:13:51AM -0700, Darrick J. Wong wrote:
> > On Wed, May 09, 2018 at 03:42:22PM +0200, Michal Hocko wrote:
[...]
> > > FS/IO code then simply calls the appropriate save function right at
> > > the layer where a lock taken from the reclaim context (e.g. shrinker)
> > > is taken and the corresponding restore function when the lock is
> 
> Seems like the second "is taken" got there by mistake

yeah, fixed. Thanks!
-- 
Michal Hocko
SUSE Labs
