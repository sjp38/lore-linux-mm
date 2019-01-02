Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64AFEC43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 14:46:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11F12218CD
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 14:46:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Hu8c64FW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11F12218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1A988E0025; Wed,  2 Jan 2019 09:46:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A02B8E0002; Wed,  2 Jan 2019 09:46:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 869558E0025; Wed,  2 Jan 2019 09:46:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5798E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 09:46:45 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id b14so11549849itd.1
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 06:46:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ssOylOFcF/4KrKPUHFHedcc63NWFBF7CN1ijXigKLks=;
        b=rXKae6ivzOxnMIXkEJS4ZU4Sf3z7Nvc2Hvan8WLFrTwNLAtrfQK25zi4Sgi++t+10/
         QyFbfjWjcLHheN2cWYHRiUHI0ITIZXAnwb+OSw+UbJwATyh9DT1sW/AyUqXe6PDZAUTD
         F8FAyNQzDZCe6eyADfZ+6eUpho4l1nMx7+hlIUM+vqlOCwbw5BhhKeVD7QpsvNVdxZxE
         r+OeQOjL3tllNtj8dRFN9r6xZ7BX7UV3U0eSxjkVEf1RydFaIVRuBNdpQKvk7jJjVD/r
         q4jJja/KvPSN8YrpyFIMjydYtstIhGgSLerSuELgpC3N6/LlV3kflq9wQAh3KFecSAPY
         JTWQ==
X-Gm-Message-State: AJcUukeyBc/LSOV4qbmUT2dm9BCIeqPtXFJ73CekzPV6Cr8wwDT088ih
	6LyVonJ043TPOxl13f30z4HJDb7N8quipUC/EZ2ycyl6Y6xD/C0glegfKo+ZgyBwJ9oYHAd/0F2
	DVTFVc44arXGsBqHyzviKQPkV0ulzYM91GzCJS8TrkdvVI6kwEN+kovoKJMXbiOS8y7f0BEv+bW
	/uaOOEWuK41H9SrFxaqENkkvCfYcxoUfi+I+HTR9JV5pWaTRWf+xvespyZTnZ5fbDH9BcLN+wa1
	R6ujZBR91iXpedoPpjl2MwNfcFDOr0n4oZMGpyOdLaukCb/JahXkawh/7/+ZRj/dlnb/W82zZib
	BMJAq4J2t7Osx+WELvE9wFjgESpIh/jwpnnYlk4uj4ANFqTy/VihpJlJ+whbrmB+Ln4KTcjyzIQ
	n
X-Received: by 2002:a24:9d1:: with SMTP id 200mr30883528itm.53.1546440405118;
        Wed, 02 Jan 2019 06:46:45 -0800 (PST)
X-Received: by 2002:a24:9d1:: with SMTP id 200mr30883503itm.53.1546440404374;
        Wed, 02 Jan 2019 06:46:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546440404; cv=none;
        d=google.com; s=arc-20160816;
        b=sAq0p+7vew2R2NYccKfpxd8U/LOfvYBpESUAWhgktXUHghxtnRqv5NLwsQHJmuaOU/
         uKMnwl9flUlQgA9Tz+9Wg3UFQv2ilWdEYzMcMGXNU39AimL3hQnY92qyL+koq6A/Hr8k
         H23m/3E+GAYtbHgNPitXt8Yg3D35GhfK/hqavgdiS4UQXbU/sEXx81EyBcLpCQa/IfAP
         kog4j5tX3zJK6F4SuiiTViHSFRAivvsItxEeLouOAFrJEZQilrMetuhle4bpJlBmwqPU
         t9QSMk6Dm7SY1b756FaPYoAKef8Q4TunA8ZNdyjMQQT24l6PqxCrKdj/GvWfw8DlT+3B
         K+ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ssOylOFcF/4KrKPUHFHedcc63NWFBF7CN1ijXigKLks=;
        b=Wghi8GOl4b2qVjE7VumVYx6EgzINOkkf99ELwCMzN9aLVUDqZRWcQdlOT8gzt1T+yP
         KsN/QNwnyggTCL/WuC+a4jMpDowBTAdlYt9qqdVlfkcz7jLGlp2jDoHjN+u/M2rGu6zl
         2MjXw/ioq//C+uzIGkblo/J9n5jpQz/EJynNd8rby2G0ELnDZXoNCZQnrOoq4GziX8IO
         5kLJkIAqKBb5xCbcqw8Nmokhxw3tjdeMTgjUfcQtqHVloFJm7W1NNT0qYn9E+3/uvbc7
         wzjwQN1q9TsKZmjbVOqHIB3PivrMUTAgquljmwV2J29rMNq+UCiy/6u8dwOE9zA6hLgi
         z4Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Hu8c64FW;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s21sor6094503iol.146.2019.01.02.06.46.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 06:46:44 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Hu8c64FW;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ssOylOFcF/4KrKPUHFHedcc63NWFBF7CN1ijXigKLks=;
        b=Hu8c64FWXWCWtwxZ0SDsWoQ6Ffc0Wnxg4h0SXXIHS06rNFT+ggjOOqeIs18GADdMwX
         0VL9Wo7GjDUaivVN/6hvwbzXFVUuZm5jvU+jcihGQ7StX5k+4ienaF53vPT+/J5dIWJh
         /ubQ1KPC7yauZNyptLJDVXmwutvoPVdIK4M4jhMR3geQ/Dib1apPGJsyQ7axzzgLoVNg
         OKZxYhwyI/Fs8Io7oYqL20j/1HfVAlbd5wxijs4mR/ydarQGM7cc9IH/TyLbs0MS13Ai
         jjyYEq5Wt0JwgT3je9CnWZ1HY64y/u/JSakpOCftKt9vltL9XUg6p3RB5xL92Jdr6Lfn
         iVZw==
X-Google-Smtp-Source: ALg8bN6xvELljIEO7Hs5tNmXuelgU8TmJW4Oq6YeAmF6anfy2jeNK9LnsxyJsKk3jrRTIKBkjsopXw8a7FHZa8xRH7g=
X-Received: by 2002:a5d:9456:: with SMTP id x22mr5006917ior.282.1546440403796;
 Wed, 02 Jan 2019 06:46:43 -0800 (PST)
MIME-Version: 1.0
References: <0000000000009ce88d05714242a8@google.com> <4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
 <9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
 <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
 <a2df1f24-f649-f5d8-0b2d-66d45b6cb61f@i-love.sakura.ne.jp>
 <20180806100928.x7anab3c3y5q4ssa@quack2.suse.cz> <e8a23623-feaf-7730-5492-b329cb0daa21@i-love.sakura.ne.jp>
 <20190102144015.GA23089@quack2.suse.cz>
In-Reply-To: <20190102144015.GA23089@quack2.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 2 Jan 2019 15:46:32 +0100
Message-ID:
 <CACT4Y+ZoVGsG=nDHffEMi-89AT6_0dzJB-zgT8xXTaMQ4JHgTQ@mail.gmail.com>
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
Message-ID: <20190102144632.Bw6V3jSqDCFop4s8G0XM9_hokRlgGkq7jBMZGE4faKA@z>

On Wed, Jan 2, 2019 at 3:40 PM Jan Kara <jack@suse.cz> wrote:
>
> On Fri 28-12-18 22:34:13, Tetsuo Handa wrote:
> > On 2018/08/06 19:09, Jan Kara wrote:
> > > On Tue 31-07-18 00:07:22, Tetsuo Handa wrote:
> > >> On 2018/07/21 5:06, Andrew Morton wrote:
> > >>> On Fri, 20 Jul 2018 19:36:23 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > >>>
> > >>>>>
> > >>>>> This report is stalling after mount() completed and process used remap_file_pages().
> > >>>>> I think that we might need to use debug printk(). But I don't know what to examine.
> > >>>>>
> > >>>>
> > >>>> Andrew, can you pick up this debug printk() patch?
> > >>>> I guess we can get the result within one week.
> > >>>
> > >>> Sure, let's toss it in -next for a while.
> > >>>
> > >>>> >From 8f55e00b21fefffbc6abd9085ac503c52a302464 Mon Sep 17 00:00:00 2001
> > >>>> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > >>>> Date: Fri, 20 Jul 2018 19:29:06 +0900
> > >>>> Subject: [PATCH] fs/buffer.c: add debug print for __getblk_gfp() stall problem
> > >>>>
> > >>>> Among syzbot's unresolved hung task reports, 18 out of 65 reports contain
> > >>>> __getblk_gfp() line in the backtrace. Since there is a comment block that
> > >>>> says that __getblk_gfp() will lock up the machine if try_to_free_buffers()
> > >>>> attempt from grow_dev_page() is failing, let's start from checking whether
> > >>>> syzbot is hitting that case. This change will be removed after the bug is
> > >>>> fixed.
> > >>>
> > >>> I'm not sure that grow_dev_page() is hanging.  It has often been
> > >>> suspected, but always is proven innocent.  Lets see.
> > >>
> > >> syzbot reproduced this problem ( https://syzkaller.appspot.com/text?tag=CrashLog&x=11f2fc44400000 ) .
> > >> It says that grow_dev_page() is returning 1 but __find_get_block() is failing forever. Any idea?
> > >
> > > Looks like some kind of a race where device block size gets changed while
> > > getblk() runs (and creates buffers for underlying page). I don't have time
> > > to nail it down at this moment can have a look into it later unless someone
> > > beats me to it.
> >
> > I feel that the frequency of hitting this problem was decreased
> > by merging loop module's ioctl() serialization patches. But this
> > problem is still there, and syzbot got a new line in
> > https://syzkaller.appspot.com/text?tag=CrashLog&x=177f889f400000 .
> >
> >   [  615.881781] __loop_clr_fd: partition scan of loop5 failed (rc=-22)
> >   [  619.059920] syz-executor4(2193): getblk(): executed=cd bh_count=0 bh_state=29
> >   [  622.069808] syz-executor4(2193): getblk(): executed=9 bh_count=0 bh_state=0
> >   [  625.080013] syz-executor4(2193): getblk(): executed=9 bh_count=0 bh_state=0
> >   [  628.089900] syz-executor4(2193): getblk(): executed=9 bh_count=0 bh_state=0
> >
> > I guess that loop module is somehow related to this problem.
>
> I had a look into this and the only good explanation for this I have is
> that sb->s_blocksize is different from (1 << sb->s_bdev->bd_inode->i_blkbits).
> If that would happen, we'd get exactly the behavior syzkaller observes
> because grow_buffers() would populate different page than
> __find_get_block() then looks up.
>
> However I don't see how that's possible since the filesystem has the block
> device open exclusively and blkdev_bszset() makes sure we also have
> exclusive access to the block device before changing the block device size.
> So changing block device block size after filesystem gets access to the
> device should be impossible.

If this is that critical and impossible to fire, maybe it makes sense
to add a corresponding debug check to some code paths?
syzkaller will immediately catch any violations if they happen.


> Anyway, could you perhaps add to your debug patch a dump of 'size' passed
> to __getblk_slow() and bdev->bd_inode->i_blkbits? That should tell us
> whether my theory is right or not. Thanks!

