Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E80148D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 05:30:45 -0400 (EDT)
Date: Wed, 30 Mar 2011 05:30:41 -0400
From: 'Christoph Hellwig' <hch@infradead.org>
Subject: Re: XFS memory allocation deadlock in 2.6.38
Message-ID: <20110330093041.GB21819@infradead.org>
References: <081DDE43F61F3D43929A181B477DCA95639B5327@MSXAOA6.twosigma.com>
 <20110324174311.GA31576@infradead.org>
 <AANLkTikwwRm6FHFtEdUg54NvmKdswQw-NPH5dtq1mXBK@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B5349@MSXAOA6.twosigma.com>
 <BANLkTin0jJevStg5P2hqsLbqMzo3o30sYg@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B534E@MSXAOA6.twosigma.com>
 <081DDE43F61F3D43929A181B477DCA95639B5359@MSXAOA6.twosigma.com>
 <20110329192434.GA10536@infradead.org>
 <081DDE43F61F3D43929A181B477DCA95639B535D@MSXAOA6.twosigma.com>
 <20110330000942.GI3008@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110330000942.GI3008@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Sean Noonan <Sean.Noonan@twosigma.com>, 'Christoph Hellwig' <hch@infradead.org>, 'Michel Lespinasse' <walken@google.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, Martin Bligh <Martin.Bligh@twosigma.com>, Trammell Hudson <Trammell.Hudson@twosigma.com>, Christos Zoulas <Christos.Zoulas@twosigma.com>, "'linux-xfs@oss.sgi.com'" <linux-xfs@oss.sgi.com>, Stephen Degler <Stephen.Degler@twosigma.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>

On Wed, Mar 30, 2011 at 11:09:42AM +1100, Dave Chinner wrote:
> +	ext_buffer = kmem_alloc(XFS_IFORK_SIZE(ip, whichfork),
> +							KM_SLEEP | KM_NOFS);

The old code didn't use KM_NOFS, and I don't think it needed it either,
as we call the iop_format handlers inside the region covered by the
PF_FSTRANS flag.

Also I think the   routine needs to be under #ifndef XFS_NATIVE_HOST, as
we do not use it for big endian builds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
