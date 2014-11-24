Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9F86B006C
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 17:17:46 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so10396233pab.28
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 14:17:46 -0800 (PST)
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com. [209.85.220.49])
        by mx.google.com with ESMTPS id fl3si22740328pab.35.2014.11.24.14.17.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 14:17:45 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so10231757pac.8
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 14:17:44 -0800 (PST)
Date: Mon, 24 Nov 2014 14:17:42 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v2 0/5] btrfs: implement swap file support
Message-ID: <20141124221742.GA15745@mew.dhcp4.washington.edu>
References: <cover.1416563833.git.osandov@osandov.com>
 <20141121101531.GB21814@mew>
 <20141121101914.GA380@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141121101914.GA380@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>

On Fri, Nov 21, 2014 at 02:19:14AM -0800, Christoph Hellwig wrote:
> On Fri, Nov 21, 2014 at 02:15:31AM -0800, Omar Sandoval wrote:
> > Sorry for the noise, looks like Christoph got back to me on the previous RFC
> > just before I sent this out -- disregard this for now.
> 
> If the NFS people are fine with this version I'd certainly welcome it as
> a first step.  Additional improvements are of course always welcome.
>
To follow up with the NFS people, there's some more review going on on the
BTRFS side, but I'd like to have the infrastructure squared away here.
Additional improvements should be mostly on the VFS side.

Thanks!
-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
