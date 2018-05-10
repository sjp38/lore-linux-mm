Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 107716B05C8
	for <linux-mm@kvack.org>; Thu, 10 May 2018 03:18:37 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q7-v6so468588pgt.11
        for <linux-mm@kvack.org>; Thu, 10 May 2018 00:18:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t184-v6si173712pfb.98.2018.05.10.00.18.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 00:18:35 -0700 (PDT)
Date: Thu, 10 May 2018 09:18:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: vmalloc with GFP_NOFS
Message-ID: <20180510071825.GC32366@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
 <20180424183536.GF30619@thunk.org>
 <20180424192542.GS17484@dhcp22.suse.cz>
 <20180509134222.GU32366@dhcp22.suse.cz>
 <20180509151351.GA4111@magnolia>
 <20180509210447.GX32366@dhcp22.suse.cz>
 <20180509220231.GD25312@magnolia>
 <20180510055825.GB32366@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180510055825.GB32366@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, Richard Weinberger <richard@nod.at>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Thu 10-05-18 07:58:25, Michal Hocko wrote:
> On Wed 09-05-18 15:02:31, Darrick J. Wong wrote:
> > On Wed, May 09, 2018 at 11:04:47PM +0200, Michal Hocko wrote:
> > > On Wed 09-05-18 08:13:51, Darrick J. Wong wrote:
> [...]
> > > > > FS resp. IO submitting code paths have to be careful when allocating
> > > > 
> > > > Not sure what 'FS resp. IO' means here -- 'FS and IO' ?
> > > > 
> > > > (Or is this one of those things where this looks like plain English text
> > > > but in reality it's some sort of markup that I'm not so familiar with?)
> > > > 
> > > > Confused because I've seen 'resp.' used as shorthand for
> > > > 'responsible'...
> > > 
> > > Well, I've tried to cover both. Filesystem and IO code paths which
> > > allocate while in sensitive context. IO submission is kinda clear but I
> > > am not sure what a general term for filsystem code paths would be. I
> > > would be greatful for any hints here.
> > 
> > "Code paths in the filesystem and IO stacks must be careful when
> > allocating memory to prevent recursion deadlocks caused by direct memory
> > reclaim calling back into the FS or IO paths and blocking on already
> > held resources (e.g. locks)." ?
> 
> Great, thanks!

I dared to extend the last part to "(e.g. locks - most commonly those
used for the transaction context)"
-- 
Michal Hocko
SUSE Labs
