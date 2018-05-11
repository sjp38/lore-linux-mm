Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5836B0611
	for <linux-mm@kvack.org>; Fri, 11 May 2018 02:18:25 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f63-v6so373290wmi.4
        for <linux-mm@kvack.org>; Thu, 10 May 2018 23:18:25 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b188-v6si365131wmb.204.2018.05.10.23.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 23:18:23 -0700 (PDT)
Date: Fri, 11 May 2018 08:22:08 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: stop using buffer heads in xfs and iomap
Message-ID: <20180511062208.GC7962@lst.de>
References: <20180509074830.16196-1-hch@lst.de> <20180510151303.GW11261@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180510151303.GW11261@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Thu, May 10, 2018 at 08:13:03AM -0700, Darrick J. Wong wrote:
> I ran xfstests on this for fun last night but hung in g/095:
> 
> FSTYP         -- xfs (debug)
> PLATFORM      -- Linux/x86_64 submarine-djwong-mtr01 4.17.0-rc4-djw
> MKFS_OPTIONS  -- -f -m reflink=1,rmapbt=1, -i sparse=1, -b size=1024, /dev/sdf
> MOUNT_OPTIONS -- /dev/sdf /opt
> 
> FWIW the stock v4 and the 'v5 with everything and 4k blocks' vms
> passed, so I guess there's a bug somewhere in the sub-page block size
> code paths...

I haven't seen that in my -b size 1024 -m relink test  I'll try your above
exact setup, too.  Is this disk or SSD?  How much memory and how many
CPUs?

Btw, I think the series might be worthwhile even if we have to delay
the sub-page blocksize support - the blocksize == pagesize code is
basically entirely separate and already very useful.  Only the last
three patches contain the small blocksize support, without that we'll
just continue using buffer heads for that case for now.
