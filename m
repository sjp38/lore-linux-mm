Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD6F56B05B8
	for <linux-mm@kvack.org>; Thu, 10 May 2018 01:58:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k27-v6so626253wre.23
        for <linux-mm@kvack.org>; Wed, 09 May 2018 22:58:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z15-v6si324479ede.189.2018.05.09.22.58.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 22:58:28 -0700 (PDT)
Date: Thu, 10 May 2018 07:58:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: vmalloc with GFP_NOFS
Message-ID: <20180510055825.GB32366@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
 <20180424183536.GF30619@thunk.org>
 <20180424192542.GS17484@dhcp22.suse.cz>
 <20180509134222.GU32366@dhcp22.suse.cz>
 <20180509151351.GA4111@magnolia>
 <20180509210447.GX32366@dhcp22.suse.cz>
 <20180509220231.GD25312@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509220231.GD25312@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, Richard Weinberger <richard@nod.at>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Wed 09-05-18 15:02:31, Darrick J. Wong wrote:
> On Wed, May 09, 2018 at 11:04:47PM +0200, Michal Hocko wrote:
> > On Wed 09-05-18 08:13:51, Darrick J. Wong wrote:
[...]
> > > > FS resp. IO submitting code paths have to be careful when allocating
> > > 
> > > Not sure what 'FS resp. IO' means here -- 'FS and IO' ?
> > > 
> > > (Or is this one of those things where this looks like plain English text
> > > but in reality it's some sort of markup that I'm not so familiar with?)
> > > 
> > > Confused because I've seen 'resp.' used as shorthand for
> > > 'responsible'...
> > 
> > Well, I've tried to cover both. Filesystem and IO code paths which
> > allocate while in sensitive context. IO submission is kinda clear but I
> > am not sure what a general term for filsystem code paths would be. I
> > would be greatful for any hints here.
> 
> "Code paths in the filesystem and IO stacks must be careful when
> allocating memory to prevent recursion deadlocks caused by direct memory
> reclaim calling back into the FS or IO paths and blocking on already
> held resources (e.g. locks)." ?

Great, thanks!
-- 
Michal Hocko
SUSE Labs
