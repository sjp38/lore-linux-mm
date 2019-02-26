Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE094C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 09:33:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96F462147C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 09:33:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96F462147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34FD28E0003; Tue, 26 Feb 2019 04:33:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FCDA8E0001; Tue, 26 Feb 2019 04:33:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EE7D8E0003; Tue, 26 Feb 2019 04:33:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3E418E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:33:24 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id o56so10269080qto.9
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:33:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3sHTTGEiC/2ePrb+dqGBf8WxpcolmkR0vMv27lYy254=;
        b=o3oNiNkwN3okjhJV2PlCx9WpeCJAWFg8XbGCaPaxzica2eqeiOzkdpPS9AVONcu8/a
         34nQHe629RghtkB208fmr+Bg+I8WtiwoHwett/LCrLhRFFFVwiRWRL0cqCho+FyUboUx
         rmPeO5zOkRMZ2SDaqa80KJSRw0zG4Zf8iijGvxBK2oMuVu2lY12LmFQy55/+ct4ovYJP
         Pa4FpOSHs9LR4DD2UL1SRNXYYaXkJw77jefGgOiusls5NpkbFJ2MjW0WLIpkovQCGbIJ
         1UI87ms5eNx0lm0V0k8VXgYdUCFHm/obI3mZfYu4NFkRBB4akJ/MQuEJtsJyg4SbVuDa
         UV1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub8b4DlHkMDya094MyRhpvq3AGvKGpBOMuuagY+CAHzD5YkZtpv
	yFeZbkx3qFaLEs3mAgZ4obkUicPqptkT6qj7ajJG8mxViVaNLHw6IJ8HpRK8nKQKbBLyYm7tF0v
	8AHmDpbQFCexjt8aa7iMfL9cEHPd4GKLlIZbsL15TOBnDaVp3yQZc+pFyrQurR94+0Q==
X-Received: by 2002:a0c:95c9:: with SMTP id t9mr9106558qvt.220.1551173604626;
        Tue, 26 Feb 2019 01:33:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZVTprPVnC7m49Sswsi15SFqlZDzJd9PSsLg19/FDbbeW9Gd65sZG+OPasq9nPHwAhNvSI3
X-Received: by 2002:a0c:95c9:: with SMTP id t9mr9106528qvt.220.1551173603861;
        Tue, 26 Feb 2019 01:33:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551173603; cv=none;
        d=google.com; s=arc-20160816;
        b=PRavg5B3tk/NxhP+caOwXgQ6LdwdpK4nwzm+U87vozkODc3Gt4t91LRNkrFlrHs5Me
         d0ilDtXODEXV/PiABZWyQ2u85qZg55bGEQnqzvsR7Ubr6Ojum5V4P/fXP0U7GX4WE8TS
         k1fJvdChPM0FHtpL5DkXthbqLJERpIDidrefg+/sOMes2g3mbxYsAlaGMo+JlyDj8Qki
         xZ0xZP6ODl5i2w5c60YwdaNC86IxFr1iuV9UuCBQ9b5EFhrpTpAamFjPkWCw3eBTnwFN
         l7OLTMQ8U1QAfTXTS1PtAzjMo9L2orunAsI8DHLV9S+GDJOuFJQneiy23hoJ3KmPIwvT
         Pe3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3sHTTGEiC/2ePrb+dqGBf8WxpcolmkR0vMv27lYy254=;
        b=uWbGZpjRr+3KPyScIbzBBjfss6oH5NGljYDwI4dDz8sDDOm/inSVv5BdZukEgbvR6G
         bWoJCWY/SCZbJy8IWjHnobWL126ioOlg1lq93Wjbc3DKrQAruRHS3lrW0RJYoCuEVRxJ
         i2FUtTiE4owEJjh+Cj0fccRnr/MQ3yDsJZQtUbBb2pYBZbzvOA5OC3ZU2KpNWfQIE+GJ
         WR/R1yWPJ91YWgFzeXBMpXuW4gE8k0x/M2fKmnarDPJqdNamj2RjfB8qWqiWCf9WgqPy
         E5aqEI8wzH6PIxachd7aBAe5OuVOrpWTj/pifrPD09SQL8DoZiEXc4cQVQ+tzN0U0Sxf
         jEOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k13si2362356qtb.230.2019.02.26.01.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 01:33:23 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C9A5081E00;
	Tue, 26 Feb 2019 09:33:21 +0000 (UTC)
Received: from ming.t460p (ovpn-8-35.pek2.redhat.com [10.72.8.35])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 75BEC5C66B;
	Tue, 26 Feb 2019 09:33:08 +0000 (UTC)
Date: Tue, 26 Feb 2019 17:33:04 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190226093302.GA24879@ming.t460p>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226045826.GJ23020@dastard>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 26 Feb 2019 09:33:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 03:58:26PM +1100, Dave Chinner wrote:
> On Mon, Feb 25, 2019 at 07:27:37PM -0800, Matthew Wilcox wrote:
> > On Tue, Feb 26, 2019 at 02:02:14PM +1100, Dave Chinner wrote:
> > > > Or what is the exact size of sub-page IO in xfs most of time? For
> > > 
> > > Determined by mkfs parameters. Any power of 2 between 512 bytes and
> > > 64kB needs to be supported. e.g:
> > > 
> > > # mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....
> > > 
> > > will have metadata that is sector sized (512 bytes), filesystem
> > > block sized (1k), directory block sized (8k) and inode cluster sized
> > > (32k), and will use all of them in large quantities.
> > 
> > If XFS is going to use each of these in large quantities, then it doesn't
> > seem unreasonable for XFS to create a slab for each type of metadata?
> 
> 
> Well, that is the question, isn't it? How many other filesystems
> will want to make similar "don't use entire pages just for 4k of
> metadata" optimisations as 64k page size machines become more
> common? There are others that have the same "use slab for sector
> aligned IO" which will fall foul of the same problem that has been
> reported for XFS....
> 
> If nobody else cares/wants it, then it can be XFS only. But it's
> only fair we address the "will it be useful to others" question
> first.....

This kind of slab cache should have been global, just like interface of
kmalloc(size).

However, the alignment requirement depends on block device's block size,
then it becomes hard to implement as genera interface, for example:

	block size: 512, 1024, 2048, 4096
	slab size: 512*N, 0 < N < PAGE_SIZE/512

For 4k page size, 28(7*4) slabs need to be created, and 64k page size
needs to create 127*4 slabs.

But, specific file system may only use some of them, and it depends
on meta data size.

Thanks,
Ming

