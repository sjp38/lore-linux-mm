Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE2E280257
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 08:17:29 -0400 (EDT)
Received: by wgck11 with SMTP id k11so87076926wgc.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 05:17:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ft15si14883161wic.69.2015.07.03.05.17.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Jul 2015 05:17:27 -0700 (PDT)
Date: Fri, 3 Jul 2015 14:17:21 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 30/51] writeback: implement and use inode_congested()
Message-ID: <20150703121721.GJ23329@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-31-git-send-email-tj@kernel.org>
 <20150630152105.GP7252@quack.suse.cz>
 <20150702014634.GF26440@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150702014634.GF26440@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Wed 01-07-15 21:46:34, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jun 30, 2015 at 05:21:05PM +0200, Jan Kara wrote:
> > Hum, is there any point in supporting NULL inode with inode_congested()?
> > That would look more like a programming bug than anything... Otherwise the
> > patch looks good to me so you can add:
> 
> Those are inherited from the existing usages and all for swapper
> space.  I think we should have a dummy inode instead of scattering
> NULL mapping->host test all over the place but that's for another day.

  Ah, OK. A comment about this would be nice.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
