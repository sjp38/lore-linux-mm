Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF2176B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 19:35:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w15-v6so7776075pge.2
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 16:35:11 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t62-v6si30657084pfd.133.2018.10.11.16.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 16:35:10 -0700 (PDT)
Date: Thu, 11 Oct 2018 16:34:43 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 01/25] xfs: add a per-xfs trace_printk macro
Message-ID: <20181011233443.GD28243@magnolia>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923114361.5546.11838344265359068530.stgit@magnolia>
 <20181011133934.GA23424@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181011133934.GA23424@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Thu, Oct 11, 2018 at 06:39:34AM -0700, Christoph Hellwig wrote:
> On Wed, Oct 10, 2018 at 09:12:23PM -0700, Darrick J. Wong wrote:
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > Add a "xfs_tprintk" macro so that developers can use trace_printk to
> > print out arbitrary debugging information with the XFS device name
> > attached to the trace output.
> 
> I can't say I'm a fan of this.  trace_printk is a debugging aid,
> and opencoding the file system name really isn't much of a burden.

<shrug> I got tired enough of typing it to add a ewwgross macro, and then
got tired enough of maintaining the patch, let's see what Dave says. :)

--D
