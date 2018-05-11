Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC626B065D
	for <linux-mm@kvack.org>; Fri, 11 May 2018 02:39:33 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id p12-v6so693418itc.7
        for <linux-mm@kvack.org>; Thu, 10 May 2018 23:39:33 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id l197-v6si558561itb.15.2018.05.10.23.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 23:39:32 -0700 (PDT)
Date: Thu, 10 May 2018 23:39:25 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: stop using buffer heads in xfs and iomap
Message-ID: <20180511063925.GH11261@magnolia>
References: <20180509074830.16196-1-hch@lst.de>
 <20180510151303.GW11261@magnolia>
 <20180511062208.GC7962@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180511062208.GC7962@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri, May 11, 2018 at 08:22:08AM +0200, Christoph Hellwig wrote:
> On Thu, May 10, 2018 at 08:13:03AM -0700, Darrick J. Wong wrote:
> > I ran xfstests on this for fun last night but hung in g/095:
> > 
> > FSTYP         -- xfs (debug)
> > PLATFORM      -- Linux/x86_64 submarine-djwong-mtr01 4.17.0-rc4-djw
> > MKFS_OPTIONS  -- -f -m reflink=1,rmapbt=1, -i sparse=1, -b size=1024, /dev/sdf
> > MOUNT_OPTIONS -- /dev/sdf /opt
> > 
> > FWIW the stock v4 and the 'v5 with everything and 4k blocks' vms
> > passed, so I guess there's a bug somewhere in the sub-page block size
> > code paths...
> 
> I haven't seen that in my -b size 1024 -m relink test  I'll try your above
> exact setup, too.  Is this disk or SSD?  How much memory and how many
> CPUs?

4 CPUs in a VM on a Nehalem-era machine, 2GB RAM, two 2.3GB virtio-scsi
disks...

...the VM host itself is a quad-core Nehalem, 24G RAM, atop an ext4 fs
on spinning rust in a raid1.

> Btw, I think the series might be worthwhile even if we have to delay
> the sub-page blocksize support - the blocksize == pagesize code is
> basically entirely separate and already very useful.  Only the last
> three patches contain the small blocksize support, without that we'll
> just continue using buffer heads for that case for now.

<shrug> I'll keep reading, it seemed generally ok until I hit the
sub-page part and my eyes glazed over. :)

--D

> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
