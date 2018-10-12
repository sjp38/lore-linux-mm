Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37A4D6B0008
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 21:22:55 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r72-v6so6134996pfj.3
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 18:22:55 -0700 (PDT)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id a8-v6si26917907pgh.396.2018.10.11.18.22.53
        for <linux-mm@kvack.org>;
        Thu, 11 Oct 2018 18:22:54 -0700 (PDT)
Date: Fri, 12 Oct 2018 12:22:43 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 25/25] xfs: remove redundant remap partial EOF block
 checks
Message-ID: <20181012012243.GU6311@dastard>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923132645.5546.97372209609060021.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153923132645.5546.97372209609060021.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Wed, Oct 10, 2018 at 09:15:26PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Now that we've moved the partial EOF block checks to the VFS helpers, we
> can remove the redundantn functionality from XFS.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

looks fine.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
-- 
Dave Chinner
david@fromorbit.com
