Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87B48C43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 15:13:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 399F32086D
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 15:13:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bPM3ObqZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 399F32086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7A278E0003; Mon, 14 Jan 2019 10:13:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E508B8E0002; Mon, 14 Jan 2019 10:13:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D40038E0003; Mon, 14 Jan 2019 10:13:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id A71B78E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 10:13:20 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id k133so9679275ite.4
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 07:13:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rMCXzL11zZdJVKGyjjgOTE2yfPh/IHwve6ZGuNPVeTI=;
        b=cMcJcrBMrN3ntc/gJ3qsQRIRyeV//KEpE82RS1OjK0SlhKe6oUU0AJB0OXHfflgu64
         9fQaLUh8OvBy5K5ewFhOSy5g/4QdRQ1ufUiIMHMLC4m8QQVjMF2cuKMZec3Iq7NFhORL
         Ja4kD29ch1YZ+ESYmerIjJm10Nqbg0WXlwD7eWsP33UwHdJB9jmV/XtMkC+wn5fEB8Oj
         9cITAPEtxnwe8P/fB1v4O6KJPNdSsP9CRy93WlxkbX638/uhkg1OInK0S+yUMHy3kITm
         autwz+T1nX/aO64XPn9uQC31K26xe7IzW1T2vh4nq5DScNXKRw9zSUxurvUrYRu9N9of
         fk7A==
X-Gm-Message-State: AJcUukdr80pifilutzMr9L6oIcU3X//df7+bkdiom1xrkWDVOi+wE36e
	FWqg9l6fSmQ03S0opWIjls2hNoBaFok07UGiMGPXj0tzRIgmXewVLtdUw0t4BIk08FMDt4qOuC2
	1poX5iXgQZCZCDmH257Qr0/6lqdmPbptNLZV0hWKpD5jl5mw5AEjzui3WjuyVAhYT4JJyI6yZwM
	/XYARVqmPYZ3wESqrWlMFdsa5NEoebGpLIKNLgPSxoUsdI3ZUklm8pqSbHPjGA725dYEcjkEEP0
	CY+KX+4g724WgmVge6FJ8//zZDuByjQgo5aUkM5C3LayiQmvTu4J/8lv3NcZZbOwjILNp8jM0Fx
	oeBOwLvlpdGAMwMhCqiaAtvVFfcIYa5zvQ63DhzVMU+OEfOVwheRlh0T6zQYpm425s5gewPE/ZU
	C
X-Received: by 2002:a24:ba0b:: with SMTP id p11mr8164554itf.113.1547478800432;
        Mon, 14 Jan 2019 07:13:20 -0800 (PST)
X-Received: by 2002:a24:ba0b:: with SMTP id p11mr8164518itf.113.1547478799714;
        Mon, 14 Jan 2019 07:13:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547478799; cv=none;
        d=google.com; s=arc-20160816;
        b=h7yk/5eV8c3ptgpSLpbLCEkkhjVHzFms633eYQqOXyhBLrFPvho1G3sm0yBvb6sOrj
         1//epvBz5y/CtDhloFimZjnKKDagz/iWLXWPdypDeYmNi+pUGE985NgylSDAcSn1Db6y
         lojOYYrkh/dnnyPhIIMs5ngoHajJgV/+CyOj57cAIR21PUkE08OMXOQWlI8urVSqPkoD
         IzqkJEMo3x/3nAoaTtLwdsdW9NAGPEkntLGV7/QaTQozDlf2L3/c9OrVwIQ0Jvp8yRc/
         sKdpIAjgkSy7Jvw4xbKVbPMVmJvDSB2qx2cBKsQUoPSI5nqed2/bLy+tI05LxU26ensh
         xpRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rMCXzL11zZdJVKGyjjgOTE2yfPh/IHwve6ZGuNPVeTI=;
        b=nZpohHxEQ6DFD5MvBlX4V+mLKccYUzm9bqJvFIuU/9pu36XCzHQvnqaBCy+zQ1Ycyv
         7kXdgD21s5ocYt2w9aJHyvuWU1qJVeIHJ+S2g02ZcelQHFgDK1r5GB9Fc0TCs9QNtlxZ
         tZfhdFlGqyyIKPz8ay2D77mV2SRndrH23aBrA31w4QKhNa4ez7aAxbkKU2Iqvj6LHP0e
         LN7ZDpnatV/VtrVV0UGhr6auUCBxunMlbQx3wnpO11UnUGjTns+MdEoxIN4u+aHsySeg
         tEinylv32m7mximjKVnFVbY0BSJ4NuF3OIQZiQB4+ERkz1o4gRv7q5S6LZnL/IdA4P3a
         njjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bPM3ObqZ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e70sor1156955itc.4.2019.01.14.07.13.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 07:13:19 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bPM3ObqZ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rMCXzL11zZdJVKGyjjgOTE2yfPh/IHwve6ZGuNPVeTI=;
        b=bPM3ObqZ7wNRQqHo6udocbzvBUUad2nKKUo94fqLj7tpcYeG3CF497NhOlrAERaRoz
         gCBfS3MDDnAzBavn9qiqznvU1n+2Ps1r4qqzlwr+yw+fBfb5xQCYwEA33J2jashiT/+S
         irKDIFk5W0eyGgOi4CPttgiqkElju67Z8vViXu25y80cxW4HDVJYbrCErp48dFZde98d
         SlFF09tkBq0cwQhnQd0vVXyuQtErt+NI7KSCvxBPNPGk71hWKAfVRvY/z1FHHyn9oVnk
         SQnbn9BxjRyqvxrTmnPMta40Nt7JJ9AZDj4GktaOwRFLeN1c8z8UOI/vqn8oy8Xnf6QZ
         uRpQ==
X-Google-Smtp-Source: ALg8bN5WvRBfsqOLCDSOWVe3ja+2vFpW/mx+e9eVUh4JxAQUQhx81xNKLW2YjG5ZKS+d5NNirpMkehWjvNXHgdehtyY=
X-Received: by 2002:a02:97a2:: with SMTP id s31mr17110047jaj.82.1547478799163;
 Mon, 14 Jan 2019 07:13:19 -0800 (PST)
MIME-Version: 1.0
References: <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
 <a2df1f24-f649-f5d8-0b2d-66d45b6cb61f@i-love.sakura.ne.jp>
 <20180806100928.x7anab3c3y5q4ssa@quack2.suse.cz> <e8a23623-feaf-7730-5492-b329cb0daa21@i-love.sakura.ne.jp>
 <20190102144015.GA23089@quack2.suse.cz> <275523c6-f750-44c2-a8a4-f3825eeab788@i-love.sakura.ne.jp>
 <20190102172636.GA29127@quack2.suse.cz> <bf209c90-3624-68cd-c0db-86a91210f873@i-love.sakura.ne.jp>
 <20190108112425.GC8076@quack2.suse.cz> <CACT4Y+bxUJ-6dLch+orY0AcjrvJhXq1=ELvHciX5M-gd5bdPpA@mail.gmail.com>
 <20190109133006.GG15397@quack2.suse.cz> <CACT4Y+bTos-xu42v4D_5JCkymjPsEFM3hiYydmnXV4fpV=sRoQ@mail.gmail.com>
In-Reply-To: <CACT4Y+bTos-xu42v4D_5JCkymjPsEFM3hiYydmnXV4fpV=sRoQ@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 14 Jan 2019 16:13:08 +0100
Message-ID:
 <CACT4Y+ZWQdzUPPwb8_KtMSwrjb_209TcN5hbUzNbUKN7dmx6oA@mail.gmail.com>
Subject: Re: INFO: task hung in generic_file_write_iter
To: Jan Kara <jack@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>, 
	Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, 
	Michal Hocko <mhocko@kernel.org>, Andi Kleen <ak@linux.intel.com>, jlayton@redhat.com, 
	LKML <linux-kernel@vger.kernel.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, tim.c.chen@linux.intel.com, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114151308.V8ijrpQTvfcGBUYWHvlofpfZOy8jzrqcopXYulZUPjY@z>

On Mon, Jan 14, 2019 at 4:11 PM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> On Wed, Jan 9, 2019 at 2:30 PM Jan Kara <jack@suse.cz> wrote:
> >
> > On Tue 08-01-19 12:49:08, Dmitry Vyukov wrote:
> > > On Tue, Jan 8, 2019 at 12:24 PM Jan Kara <jack@suse.cz> wrote:
> > > >
> > > > On Tue 08-01-19 19:04:06, Tetsuo Handa wrote:
> > > > > On 2019/01/03 2:26, Jan Kara wrote:
> > > > > > On Thu 03-01-19 01:07:25, Tetsuo Handa wrote:
> > > > > >> On 2019/01/02 23:40, Jan Kara wrote:
> > > > > >>> I had a look into this and the only good explanation for this I have is
> > > > > >>> that sb->s_blocksize is different from (1 << sb->s_bdev->bd_inode->i_blkbits).
> > > > > >>> If that would happen, we'd get exactly the behavior syzkaller observes
> > > > > >>> because grow_buffers() would populate different page than
> > > > > >>> __find_get_block() then looks up.
> > > > > >>>
> > > > > >>> However I don't see how that's possible since the filesystem has the block
> > > > > >>> device open exclusively and blkdev_bszset() makes sure we also have
> > > > > >>> exclusive access to the block device before changing the block device size.
> > > > > >>> So changing block device block size after filesystem gets access to the
> > > > > >>> device should be impossible.
> > > > > >>>
> > > > > >>> Anyway, could you perhaps add to your debug patch a dump of 'size' passed
> > > > > >>> to __getblk_slow() and bdev->bd_inode->i_blkbits? That should tell us
> > > > > >>> whether my theory is right or not. Thanks!
> > > > > >>>
> > > > >
> > > > > Got two reports. 'size' is 512 while bdev->bd_inode->i_blkbits is 12.
> > > > >
> > > > > https://syzkaller.appspot.com/text?tag=CrashLog&x=1237c3ab400000
> > > > >
> > > > > [  385.723941][  T439] kworker/u4:3(439): getblk(): executed=9 bh_count=0 bh_state=0 bdev_super_blocksize=512 size=512 bdev_super_blocksize_bits=9 bdev_inode_blkbits=12
> > > > > (...snipped...)
> > > > > [  568.159544][  T439] kworker/u4:3(439): getblk(): executed=9 bh_count=0 bh_state=0 bdev_super_blocksize=512 size=512 bdev_super_blocksize_bits=9 bdev_inode_blkbits=12
> > > >
> > > > Right, so indeed the block size in the superblock and in the block device
> > > > gets out of sync which explains why we endlessly loop in the buffer cache
> > > > code. The superblock uses blocksize of 512 while the block device thinks
> > > > the set block size is 4096.
> > > >
> > > > And after staring into the code for some time, I finally have a trivial
> > > > reproducer:
> > > >
> > > > truncate -s 1G /tmp/image
> > > > losetup /dev/loop0 /tmp/image
> > > > mkfs.ext4 -b 1024 /dev/loop0
> > > > mount -t ext4 /dev/loop0 /mnt
> > > > losetup -c /dev/loop0
> > > > l /mnt
> > > > <hangs>
> > > >
> > > > And the problem is that LOOP_SET_CAPACITY ioctl ends up reseting block
> > > > device block size to 4096 by calling bd_set_size(). I have to think how to
> > > > best fix this...
> > > >
> > > > Thanks for your help with debugging this!
> > >
> > > Wow! I am very excited.
> > > We have 587 open "task hung" reports, I suspect this explains lots of them.
> > > What would be some pattern that we can use to best-effort distinguish
> > > most manifestations? Skimming through few reports I see "inode_lock",
> > > "get_super", "blkdev_put" as common indicators. Anything else?
> >
> > Well, there will be always looping task with __getblk_gfp() on its stack
> > (which should be visible in the stacktrace generated by the stall
> > detector). Then there can be lots of other processes getting blocked due to
> > locks and other resources held by this task...
>
>
> Once we have a fix, I plan to do a sweep over existing open "task
> hung" reports and dup lots of them onto this one. Probably preferring
> to over-sweep rather then to under-sweep because there are too many of
> them and lots does not seem to be actionable otherwise.
> Tetsuo, do you have comments before I start?

Also, is it possible to add some kind of WARNING for this condition?
Taking into account how much effort it too to debug, looks like a
useful check. Or did I ask this already...

