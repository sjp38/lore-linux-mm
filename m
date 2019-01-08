Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6D34C43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 11:49:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62551206B7
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 11:49:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ifImmzUk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62551206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9A768E0076; Tue,  8 Jan 2019 06:49:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4A908E0038; Tue,  8 Jan 2019 06:49:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D39898E0076; Tue,  8 Jan 2019 06:49:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD5198E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:49:21 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id p21so3007308itb.8
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:49:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=UYiOeKvvjCy/nZN8BIg7I+uAiPR7TR44LEWFvR+29rE=;
        b=swqmcbVzz7KKLSrg6oAvaBb0yZi8TeKF+HkP+yVsxdIzn/ABYbyuukSs9gENXRhpzC
         e5UIdOQSemSnvQ08lX5bloy3NQj86kFazMWtxmnGXmT8LITHknv0HZLiy75FTFINRhCC
         sfPePV+ORJCCsEYkGPiv6BbC2txcfROBJxegWDi3qKuw0fpC+quZ3/TDOKNs06SChQA3
         krQpWy5NpaIrZ5deVB+CMl08v+oUBZ1mXiyJDebjNPpVOrLxJB01kdwGxxU3Qi3Z14LX
         ZoiKTwLdKKPMIxlkeh+tr1aTyK05MpOlWwbwZkIE+oBOkyw9d9zsuq0Wtept2jvIpgqx
         hQqA==
X-Gm-Message-State: AJcUuke2pP2KqQpQD4dFnc1bP4j/3QtCeWIKsGVs2USN2py3Tlh/tkY1
	5PYS/J1cZn6Boq4z9v6IFlJ8kqI6vZ4WeYAdODEj6afOrLFrQGmWlMBJsIAZZckcmMWpv5p1JAP
	os6hLbae9CetaHFPWnQAr096CtAsgEtGblGTjt3k5bciInsVhjTtbUctba40GHUgh6Cmx5KqZUi
	85w/ZF15L9nOnA6skBwWdjCE5zKa64BYEQ2Krs5kLyA3p02mMZbiY5jWke3XAitLTGez2cEmbli
	YB+JDV5k13SP8RCFd6QlKY29sJZ1rsXe2/eR8g8DxyMRCcJn1tyKP5IlDk/JSmazRxDJxJW2dSL
	bNATA2EAxA/VubtCsCfDx4fZOEhUD6KmogNUqdAB0RXZx9MSLndMFbQIbtJS3isrqcPs+7wuiRA
	l
X-Received: by 2002:a24:8a44:: with SMTP id v65mr1010803itd.67.1546948161365;
        Tue, 08 Jan 2019 03:49:21 -0800 (PST)
X-Received: by 2002:a24:8a44:: with SMTP id v65mr1010780itd.67.1546948160591;
        Tue, 08 Jan 2019 03:49:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546948160; cv=none;
        d=google.com; s=arc-20160816;
        b=irsuEG2zw2Y60+gCU2yA1FJDPlMWBigFiO3+MdlAp94+r1KWVnQf006ci5uejAcLlq
         XgsTWf9DkQ+N8dlTXNp3hcZ3msop3EBHbTFEyXq73/EmwkR0Y+/g62ONaGjysk+l/w/O
         IT5NyClLfMHJ0WdnopjVJV+7E7g2/qPgJtUEuneGnz9nzYfBA/c3HLWMNlQpYtwUjZCC
         5huG3d7s+j81idhqv36kMfc3w67CkwhQwHfvakU9mMUdRAQJspiG2nPX2Fam2fMkFSCT
         Z/swDHXXNg9644Q34GQRFr7awwTpoKBd7ZDioNvx5AkR32fX+kDiMa/POlZ9au7NL0Ai
         +Fxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UYiOeKvvjCy/nZN8BIg7I+uAiPR7TR44LEWFvR+29rE=;
        b=rKnRKF3MM6SPp4bGoduFdDKStw6naapiBc8zRMK/VCl4AM4i8jXEeAEcd4s6fMJp5n
         Gv+SNt3hL3BxS08zLoP3iQDU+YI2qvAMkK9SG5Qr7+x7mwkZdj4gVUdR8t668a4PhqUp
         mFpzXUgacwGIi739GS/GNZqAyyyQDEhycJ9BA3o+QhzwL71+ao5eIIH572667wgRdSsM
         NtyWCfAYZAmBNVUwXP8VCA2/vqPUSzCc2pbkDJwy72Re4iM8JIo/maCyyBQ3KQOHJHrP
         2893r3T42G3dTYXH4gTil6h2Y1u+wx6Gd2pWM1gMubO7sP5gaa2g6u79RftFIo+92RiG
         Gl6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ifImmzUk;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 5sor17875107itx.25.2019.01.08.03.49.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 03:49:20 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ifImmzUk;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UYiOeKvvjCy/nZN8BIg7I+uAiPR7TR44LEWFvR+29rE=;
        b=ifImmzUkZ4YOobm7FKBmQujA7lx01M+r6LQXcpuYmUexOR2QWBPmgZBiFAYHEnfCnz
         2yYb9RPOIDclUyaep5KViGIJ0HxwW5Va6DJU+7Y26veY+iX/btwMtWrLQ9OmzxxQF4gN
         7p07I2DwPZl+HaZu02kQc6OhPnFBp0WoQ1TpbCUwV0iV+h66IjGNHYLMTfgsDQB4BoN8
         zbVHqAplqmBKz5qb2Ln9nZtBTxjAA9l0kGDgXxZbsSEgrJBMeSWcABYEKAd7kpNB/fxM
         aQccAVpGCrWp8Ff+jl5Mx1XWtoVAfPr7/7CKfm0YAz0k5SmdhEZiqyT7rZxj6fbJxGRR
         teQA==
X-Google-Smtp-Source: ALg8bN7S7HoDwKZQ+7GoujWB6nSgYGh8A1BD2KSSEvXraiadJGJyBcWWBNAu1EBukbpSUQhq8YpdodxGJygcW8wAD7Q=
X-Received: by 2002:a24:6511:: with SMTP id u17mr1069772itb.12.1546948159977;
 Tue, 08 Jan 2019 03:49:19 -0800 (PST)
MIME-Version: 1.0
References: <4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
 <9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
 <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
 <a2df1f24-f649-f5d8-0b2d-66d45b6cb61f@i-love.sakura.ne.jp>
 <20180806100928.x7anab3c3y5q4ssa@quack2.suse.cz> <e8a23623-feaf-7730-5492-b329cb0daa21@i-love.sakura.ne.jp>
 <20190102144015.GA23089@quack2.suse.cz> <275523c6-f750-44c2-a8a4-f3825eeab788@i-love.sakura.ne.jp>
 <20190102172636.GA29127@quack2.suse.cz> <bf209c90-3624-68cd-c0db-86a91210f873@i-love.sakura.ne.jp>
 <20190108112425.GC8076@quack2.suse.cz>
In-Reply-To: <20190108112425.GC8076@quack2.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 8 Jan 2019 12:49:08 +0100
Message-ID:
 <CACT4Y+bxUJ-6dLch+orY0AcjrvJhXq1=ELvHciX5M-gd5bdPpA@mail.gmail.com>
Subject: Re: INFO: task hung in generic_file_write_iter
To: Jan Kara <jack@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>, 
	Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, 
	Michal Hocko <mhocko@kernel.org>, Andi Kleen <ak@linux.intel.com>, jlayton@redhat.com, 
	LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, tim.c.chen@linux.intel.com, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108114908.hLNwsGJNIoIH__Je0o2MEYObmgi7-Pvaea08S5erYpk@z>

On Tue, Jan 8, 2019 at 12:24 PM Jan Kara <jack@suse.cz> wrote:
>
> On Tue 08-01-19 19:04:06, Tetsuo Handa wrote:
> > On 2019/01/03 2:26, Jan Kara wrote:
> > > On Thu 03-01-19 01:07:25, Tetsuo Handa wrote:
> > >> On 2019/01/02 23:40, Jan Kara wrote:
> > >>> I had a look into this and the only good explanation for this I have is
> > >>> that sb->s_blocksize is different from (1 << sb->s_bdev->bd_inode->i_blkbits).
> > >>> If that would happen, we'd get exactly the behavior syzkaller observes
> > >>> because grow_buffers() would populate different page than
> > >>> __find_get_block() then looks up.
> > >>>
> > >>> However I don't see how that's possible since the filesystem has the block
> > >>> device open exclusively and blkdev_bszset() makes sure we also have
> > >>> exclusive access to the block device before changing the block device size.
> > >>> So changing block device block size after filesystem gets access to the
> > >>> device should be impossible.
> > >>>
> > >>> Anyway, could you perhaps add to your debug patch a dump of 'size' passed
> > >>> to __getblk_slow() and bdev->bd_inode->i_blkbits? That should tell us
> > >>> whether my theory is right or not. Thanks!
> > >>>
> >
> > Got two reports. 'size' is 512 while bdev->bd_inode->i_blkbits is 12.
> >
> > https://syzkaller.appspot.com/text?tag=CrashLog&x=1237c3ab400000
> >
> > [  385.723941][  T439] kworker/u4:3(439): getblk(): executed=9 bh_count=0 bh_state=0 bdev_super_blocksize=512 size=512 bdev_super_blocksize_bits=9 bdev_inode_blkbits=12
> > (...snipped...)
> > [  568.159544][  T439] kworker/u4:3(439): getblk(): executed=9 bh_count=0 bh_state=0 bdev_super_blocksize=512 size=512 bdev_super_blocksize_bits=9 bdev_inode_blkbits=12
>
> Right, so indeed the block size in the superblock and in the block device
> gets out of sync which explains why we endlessly loop in the buffer cache
> code. The superblock uses blocksize of 512 while the block device thinks
> the set block size is 4096.
>
> And after staring into the code for some time, I finally have a trivial
> reproducer:
>
> truncate -s 1G /tmp/image
> losetup /dev/loop0 /tmp/image
> mkfs.ext4 -b 1024 /dev/loop0
> mount -t ext4 /dev/loop0 /mnt
> losetup -c /dev/loop0
> l /mnt
> <hangs>
>
> And the problem is that LOOP_SET_CAPACITY ioctl ends up reseting block
> device block size to 4096 by calling bd_set_size(). I have to think how to
> best fix this...
>
> Thanks for your help with debugging this!

Wow! I am very excited.
We have 587 open "task hung" reports, I suspect this explains lots of them.
What would be some pattern that we can use to best-effort distinguish
most manifestations? Skimming through few reports I see "inode_lock",
"get_super", "blkdev_put" as common indicators. Anything else?

