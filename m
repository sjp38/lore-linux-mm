Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 40D39280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 13:07:13 -0400 (EDT)
Received: by ykdr198 with SMTP id r198so100096132ykd.3
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 10:07:13 -0700 (PDT)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id p127si6633179ywc.99.2015.07.03.10.07.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 10:07:12 -0700 (PDT)
Received: by ykdv136 with SMTP id v136so100491243ykd.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 10:07:12 -0700 (PDT)
Date: Fri, 3 Jul 2015 13:07:10 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 30/51] writeback: implement and use inode_congested()
Message-ID: <20150703170710.GF5273@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-31-git-send-email-tj@kernel.org>
 <20150630152105.GP7252@quack.suse.cz>
 <20150702014634.GF26440@mtj.duckdns.org>
 <20150703121721.GJ23329@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150703121721.GJ23329@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri, Jul 03, 2015 at 02:17:21PM +0200, Jan Kara wrote:
> On Wed 01-07-15 21:46:34, Tejun Heo wrote:
> > Hello,
> > 
> > On Tue, Jun 30, 2015 at 05:21:05PM +0200, Jan Kara wrote:
> > > Hum, is there any point in supporting NULL inode with inode_congested()?
> > > That would look more like a programming bug than anything... Otherwise the
> > > patch looks good to me so you can add:
> > 
> > Those are inherited from the existing usages and all for swapper
> > space.  I think we should have a dummy inode instead of scattering
> > NULL mapping->host test all over the place but that's for another day.
> 
>   Ah, OK. A comment about this would be nice.

Will add.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
