Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id BBBCB6B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 03:36:03 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 19so1994913ykq.8
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 00:36:03 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id t26si4569525yht.238.2014.01.23.00.36.01
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 00:36:02 -0800 (PST)
Date: Thu, 23 Jan 2014 19:35:58 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140123083558.GQ13997@dastard>
References: <20140122151913.GY4963@suse.de>
 <1390410233.1198.7.camel@ret.masoncoding.com>
 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
 <1390413819.1198.20.camel@ret.masoncoding.com>
 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
 <52E00B28.3060609@redhat.com>
 <1390415703.2372.62.camel@dabdike.int.hansenpartnership.com>
 <52E0106B.5010604@redhat.com>
 <1390419019.2372.89.camel@dabdike.int.hansenpartnership.com>
 <20140122115002.bb5d01dee836b567a7aad157@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140122115002.bb5d01dee836b567a7aad157@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, Chris Mason <clm@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mgorman@suse.de" <mgorman@suse.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, Ric Wheeler <rwheeler@redhat.com>

On Wed, Jan 22, 2014 at 11:50:02AM -0800, Andrew Morton wrote:
> On Wed, 22 Jan 2014 11:30:19 -0800 James Bottomley <James.Bottomley@hansenpartnership.com> wrote:
> 
> > But this, I think, is the fundamental point for debate.  If we can pull
> > alignment and other tricks to solve 99% of the problem is there a need
> > for radical VM surgery?  Is there anything coming down the pipe in the
> > future that may move the devices ahead of the tricks?
> 
> I expect it would be relatively simple to get large blocksizes working
> on powerpc with 64k PAGE_SIZE.  So before diving in and doing huge
> amounts of work, perhaps someone can do a proof-of-concept on powerpc
> (or ia64) with 64k blocksize.

Reality check: 64k block sizes on 64k page Linux machines has been
used in production on XFS for at least 10 years. It's exactly the
same case as 4k block size on 4k page size - one page, one buffer
head, one filesystem block.

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
