Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15710C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 21:38:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C630220863
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 21:38:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C630220863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A4508E0007; Wed, 27 Feb 2019 16:38:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 754A58E0001; Wed, 27 Feb 2019 16:38:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66B678E0007; Wed, 27 Feb 2019 16:38:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 204858E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 16:38:45 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w17so13339218plp.23
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:38:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OOb+UdnydXkcrC95JaiHxnoAvAPkV8uTZpfUCkBi9jM=;
        b=V9aQxn0baRRsbPQb7FayytRdecnsxt7BtswpDG19B4so1H5uLV+n9Li165YNINlGaV
         NGpH016XDKXytMEvmvsauDYN9t9T8ksoaTw7EBCrHb5D2IJsVbDo5Xt69f4+lXRk8eIa
         SqA6bKF0ZOjR8cZEYbWGqxP8hj3zZD/4VchEYZatRDMYBKbc7/UU+dwz8s1yByVxsE+9
         LDzBKaBfY4+/ARtqnIPPsfelk6DURszEHPlDyNjgSvmCXP9MIteAMGL+0cV6oYo5syCX
         r34gmWDqzuS5gFcx8gDbEMWTHazEcJP84BcPNg//vI01QoM2Xft1s1bt73EIidbZxhbi
         nVyw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAubi5Kqejrj4dFILDSwT/N8CgGNa2en4B+nqhQEmTgr99+9O8G/G
	xmJrUM3hw8QKYINq7FAflACuPJYeXs0OKSWPAZOsfeih1BoMH7h0VfFcUgN79OjXlqIegfbz3Wg
	1Ehg4jTz7c8hNcTnQnuR/io9vrc+BOe04ldoM3kijLsjftZmAMcWy/T4LaqlDDEQ=
X-Received: by 2002:a63:9246:: with SMTP id s6mr4939735pgn.349.1551303524740;
        Wed, 27 Feb 2019 13:38:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IadRRbZw01lO9tjBk2MFjp7/CL81WCNy/S2u15t8DhBnihQrjF8ACCn4sAS7QBDwa14d3oD
X-Received: by 2002:a63:9246:: with SMTP id s6mr4939679pgn.349.1551303523721;
        Wed, 27 Feb 2019 13:38:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551303523; cv=none;
        d=google.com; s=arc-20160816;
        b=WdQEsja7dNZPlL9aM7BofbWtitPhEVweGOM16rvcIuWck58YEfYRnZ68qJJTTOXN1i
         yULUMafD3JUHvw7TEjpGRD5To4fAMU0TC3qwLp+TRL9q2+Tf1P81f5/cQAcRqVpcbJki
         wqjwEl3PG3eGetZlps/Pmx4wlY9+7q1mOQDuh7DLJxtjUBZXjsGjJT5KXiQf89YN+fBw
         ch33nQyF8lCfeMmbsQOlT6E0Y9xaRmwMwsJ4lrOQyRmJdIffVYwbejC4n6cuuaqTKzsL
         ChFyern6eQJvgPnXsWOIO3fG7cTNSB8k+qhqNVwswaFo7jAa9XtXNhkgM6+jn++VBp+u
         ULIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OOb+UdnydXkcrC95JaiHxnoAvAPkV8uTZpfUCkBi9jM=;
        b=C8k6ZkycOB3L/pMCdDXJgkWBI0X3WAorXOkClUccmM4s2y5GfIPcq3Su3iYwGV8KzT
         3uve1y0uSW2KnWhPTkwkHwZQvorRs8iEhktxa7zU9ZmXQYwgylMOhpZ1o5rpj1LRtDhl
         z9qj+p9dS/VvKMO70ryw7A1CrJ/YK7uG5+dslKK4OUbMf1DnyoWwjuKJ8T+OZfMUJu2I
         8sS3If/kfmCgPE8/8iZnZsXM02D+YEJBoHUWrCAGWYMUuoT3axjmt4rZyt5u39A37s22
         C2XOMOM9ZcQjRyMDbAYgcmmlpKT1cjl5xYYFLIVVKi8Xlhmb7M/w57EVTTLpSKL95uMb
         2ejQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id p8si13843559plk.257.2019.02.27.13.38.42
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 13:38:43 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.141;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl2.internode.on.net with ESMTP; 28 Feb 2019 08:08:41 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gz6uV-0008PY-Rc; Thu, 28 Feb 2019 08:38:39 +1100
Date: Thu, 28 Feb 2019 08:38:39 +1100
From: Dave Chinner <david@fromorbit.com>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, Ming Lei <ming.lei@redhat.com>,
	Ming Lei <tom.leiming@gmail.com>, Vlastimil Babka <vbabka@suse.cz>,
	"open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>,
	Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	linux-block <linux-block@vger.kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190227213839.GG16436@dastard>
References: <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
 <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
 <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
 <20190226121209.GC11592@bombadil.infradead.org>
 <20190226123545.GA6163@ming.t460p>
 <20190226130230.GD11592@bombadil.infradead.org>
 <20190226134247.GA30942@ming.t460p>
 <20190226140440.GF11592@bombadil.infradead.org>
 <20190226161433.GH21626@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226161433.GH21626@magnolia>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 08:14:33AM -0800, Darrick J. Wong wrote:
> On Tue, Feb 26, 2019 at 06:04:40AM -0800, Matthew Wilcox wrote:
> > On Tue, Feb 26, 2019 at 09:42:48PM +0800, Ming Lei wrote:
> > > On Tue, Feb 26, 2019 at 05:02:30AM -0800, Matthew Wilcox wrote:
> > > > Wait, we're imposing a ridiculous amount of complexity on XFS for no
> > > > reason at all?  We should just change this to 512-byte alignment.  Tying
> > > > it to the blocksize of the device never made any sense.
> > > 
> > > OK, that is fine since we can fallback to buffered IO for loop in case of
> > > unaligned dio.
> > > 
> > > Then something like the following patch should work for all fs, could
> > > anyone comment on this approach?
> > 
> > That's not even close to what I meant.
> > 
> > diff --git a/fs/direct-io.c b/fs/direct-io.c
> > index ec2fb6fe6d37..dee1fc47a7fc 100644
> > --- a/fs/direct-io.c
> > +++ b/fs/direct-io.c
> > @@ -1185,18 +1185,20 @@ do_blockdev_direct_IO(struct kiocb *iocb, struct inode *inode,
> 
> Wait a minute, are you all saying that /directio/ is broken on XFS too??
> XFS doesn't use blockdev_direct_IO anymore.

No, loop devices w/ direct IO is a complete red herring. It's the
same issue - the upper filesystem is sending down unaligned bios
to the loop device, which is then just passing them on to the
underlying filesystem via DIO, and the DIO code in the lower
filesystem saying "that user memory buffer ain't aligned to my
logical sector size" and rejecting it.

Actually, in XFS's case, it doesn't care about memory buffer
alignment - it's the iomap code that is rejecting it when mapping
the memory buffer to a bio in iomap_dio_bio_actor():

	unsigned int blkbits = blksize_bits(bdev_logical_block_size(iomap->bdev));
.....
	unsigned int align = iov_iter_alignment(dio->submit.iter);
.....
	if ((pos | length | align) & ((1 << blkbits) - 1))
		return -EINVAL;

IOWs, if the memory buffer is not aligned to the logical block size
of the underlying device (which defaults to 512 bytes) then it will
be rejected by the lower filesystem...

> I thought we were talking about alignment of XFS metadata buffers
> (xfs_buf.c), which is a very different topic.

Yup, it's the same problem, just a different symptom. Fix the
unaligned buffer problem, we fix the loop dev w/ direct-io problem,
too.

FWIW, this "filesystem image sector size mismatch" problem has been
around for many, many years - the same issue that occurs with loop
devices when you try to mount a 512 byte sector image on a hard 4k
sector host filesystem/storage device using direct IO in the loop
device. This isn't a new thing at all - if you want to use direct IO
to manipulate filesystem images, you actually need to know what you
are doing....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

