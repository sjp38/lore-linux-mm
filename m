Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58E826B0253
	for <linux-mm@kvack.org>; Sun, 29 Oct 2017 17:52:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h28so9828925pfh.16
        for <linux-mm@kvack.org>; Sun, 29 Oct 2017 14:52:54 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id l12si9359106pfd.342.2017.10.29.14.52.52
        for <linux-mm@kvack.org>;
        Sun, 29 Oct 2017 14:52:53 -0700 (PDT)
Date: Mon, 30 Oct 2017 08:52:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 00/13] dax: fix dma vs truncate and remove 'page-less'
 support
Message-ID: <20171029215233.GF3666@dastard>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171020074750.GA13568@lst.de>
 <20171020093148.GA20304@lst.de>
 <20171026105850.GA31161@quack2.suse.cz>
 <1509061831.25213.2.camel@intel.com>
 <20171027064854.GE3666@dastard>
 <CAA9_cmdx7T2jnfw6TvL0_3ytfs-h-X06uF3_7Ex-YP12YKpwng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmdx7T2jnfw6TvL0_3ytfs-h-X06uF3_7Ex-YP12YKpwng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "jack@suse.cz" <jack@suse.cz>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "bfields@fieldses.org" <bfields@fieldses.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "paulus@samba.org" <paulus@samba.org>, "Hefty, Sean" <sean.hefty@intel.com>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "dledford@redhat.com" <dledford@redhat.com>, "hch@lst.de" <hch@lst.de>, "jgunthorpe@obsidianresearch.com" <jgunthorpe@obsidianresearch.com>, "hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Fri, Oct 27, 2017 at 01:42:16PM +0200, Dan Williams wrote:
> [replying from my phone, please forgive formatting]
> 
> On Friday, October 27, 2017, Dave Chinner <david@fromorbit.com> wrote:
> 
> 
> > > Here are the two primary patches in
> > > the series, do you think the extent-busy approach would be cleaner?
> >
> > The XFS_DAXDMA....
> >
> > $DEITY that patch is so ugly I can't even bring myself to type it.
> 
> 
> Right, and so is the problem it's trying to solve. So where do you want to
> go from here?
> 
> I could go back to the FL_ALLOCATED approach, but use page idle callbacks
> instead of polling for the lease end notification. Or do we want to try
> busy extents? My concern with busy extents is that it requires more per-fs
> code.

I don't care if it takes more per-fs code to solve the problem -
dumping butt-ugly, nasty locking crap into filesystems that
filesystem developers are completely unable to test is about the
worst possible solution you can come up with.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
