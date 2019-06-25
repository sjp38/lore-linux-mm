Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FFDEC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:08:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CE9620665
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:08:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CE9620665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADA896B0003; Tue, 25 Jun 2019 03:08:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8AD68E0003; Tue, 25 Jun 2019 03:08:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9797A8E0002; Tue, 25 Jun 2019 03:08:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 462366B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:08:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so24215593edr.13
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:08:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ywoJoB1QtyyrG5KEQvKI03l1UYF9axIDMCYfP3oZi1M=;
        b=ACIN3MLPietmodxGhYPaA3IJsnULR/d7FmOI7KSn7P02dQcIKOnYWwY3Enb1ZoiCg0
         8RO7q291apGcc2i3VhHrphBagBaBdqbJqsTyqSOpjuvJxtnqwLafiDCI9r+Vb/8rrqv3
         +yaBAeMyl56H7/MuOFKrL1OQ//mrznuZ+3UrWj4YPyXEntIzquGSRUHbV9BloVvTNrFM
         t5Dlq/Chi7y3+2Dk7rscgpOqDnV+so2vietRccwvYgyx0Scmq4iOmuH+RPQjFrw7+sZt
         6rI0HkAfGqe9jGBvqhENO5/Qwm8ecIK6Stx8GcPIFdiGYhymT8KzS8b2ywf4XWMZpU/J
         nXww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWyzCcGkKxyeFGRqSiPLemNez06qCv4VubNA6KrhnLPXF34i8HL
	ZPKBW8baSRgTDGsiyXoZBSPRDO3aAygvGUuTGFeME8trNGXNNOp0AAQdLQ+gLjHruzrhoyvWZiq
	KrrtoBTZNfZVcLHOMMFGRpGCChBwlVnITZsycNfidqOPZUCKPvdNrWxBGQSUWo4NAqQ==
X-Received: by 2002:aa7:c486:: with SMTP id m6mr104657354edq.298.1561446487836;
        Tue, 25 Jun 2019 00:08:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygphrX6+3A33Vrsi7Z+GvFbq6GglX3FP0JAOZiOu2vFHgZ2iOtRJgxISid46kIkRlMDM30
X-Received: by 2002:aa7:c486:: with SMTP id m6mr104657286edq.298.1561446486984;
        Tue, 25 Jun 2019 00:08:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561446486; cv=none;
        d=google.com; s=arc-20160816;
        b=K6hGtB01ab+PhOrwGlCfg7f9SFEgGT+6nsq+bI5B1LeBcd6PPju4reUW6lvImgrrBJ
         4hYTcruMBQuxDRni5Xd/2BT2MMMXv6IzDAS4V0cCNxel0VNmEYZTqp8KCFkWe9pSl63s
         RYPtsQy5UolsgJ0G8JSh32lZZ7K1qb1f+7p+4aKXY/zV2Jxkx7Sz80Hm+hBVOW9YTzEv
         4QGli+2T0I4QQLr3tzwmeCyPYOw/ZUtzKIAzHwXqcqxWDzReCaJLkBaGrrey8LIS483I
         k+ocrVg6T3ITu1AIGqgzptn212vduP7HGrGYISXQdn9SjvFMsDaatIeIOSppsblx7K9z
         YQ2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ywoJoB1QtyyrG5KEQvKI03l1UYF9axIDMCYfP3oZi1M=;
        b=GgLblXamT7jVXfqw46USgX17U4NF9J7IZMjaA3ha7AX5NCR5s9Js9YE/d1SxSjm42h
         Z1keDBjjzi/m8o+YtiWDY8ANTAQwl/OHSap17eGFR86WGjb7vZSkfDoJ7yh6r8LobBwJ
         ezR7og2CLoDUCDscw2A2GHW85yr/oAeUOfIRSaUcpDl1w5I6W7RZlm/I70bnA0CtTWmv
         FNhP0KdIqoOWSRfsgIZCFxaVgmH8q5MO4fjqA5Op+/MqvT2/1pWih2IraY7FVnji8hch
         w2MKG5oE0GkuPZ2sTjEf6FIrh8jQPpzKmT7hg5SfXGihPR2+kSIJ2oT0fBPDOFtgJOMo
         pCOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si8221363eju.23.2019.06.25.00.08.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:08:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 05584ADF2;
	Tue, 25 Jun 2019 07:08:05 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id E62D81E2F23; Tue, 25 Jun 2019 09:08:04 +0200 (CEST)
Date: Tue, 25 Jun 2019 09:08:04 +0200
From: Jan Kara <jack@suse.cz>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Jan Kara <jack@suse.cz>, linux-efi@vger.kernel.org,
	linux-btrfs@vger.kernel.org, yuchao0@huawei.com, linux-mm@kvack.org,
	clm@fb.com, adilger.kernel@dilger.ca, matthew.garrett@nebula.com,
	linux-nilfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	devel@lists.orangefs.org, josef@toxicpanda.com,
	reiserfs-devel@vger.kernel.org, viro@zeniv.linux.org.uk,
	dsterba@suse.com, jaegeuk@kernel.org, tytso@mit.edu,
	ard.biesheuvel@linaro.org, linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
	jk@ozlabs.org, jack@suse.com, linux-fsdevel@vger.kernel.org,
	linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com
Subject: Re: [Ocfs2-devel] [PATCH 2/7] vfs: flush and wait for io when
 setting the immutable flag via SETFLAGS
Message-ID: <20190625070804.GA31527@quack2.suse.cz>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
 <156116142734.1664939.5074567130774423066.stgit@magnolia>
 <20190624113737.GG32376@quack2.suse.cz>
 <20190624215817.GE1611011@magnolia>
 <20190625030439.GA5379@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625030439.GA5379@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 24-06-19 20:04:39, Darrick J. Wong wrote:
> On Mon, Jun 24, 2019 at 02:58:17PM -0700, Darrick J. Wong wrote:
> > On Mon, Jun 24, 2019 at 01:37:37PM +0200, Jan Kara wrote:
> > > On Fri 21-06-19 16:57:07, Darrick J. Wong wrote:
> > > > From: Darrick J. Wong <darrick.wong@oracle.com>
> > > > 
> > > > When we're using FS_IOC_SETFLAGS to set the immutable flag on a file, we
> > > > need to ensure that userspace can't continue to write the file after the
> > > > file becomes immutable.  To make that happen, we have to flush all the
> > > > dirty pagecache pages to disk to ensure that we can fail a page fault on
> > > > a mmap'd region, wait for pending directio to complete, and hope the
> > > > caller locked out any new writes by holding the inode lock.
> > > > 
> > > > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > > 
> > > Seeing the way this worked out, is there a reason to have separate
> > > vfs_ioc_setflags_flush_data() instead of folding the functionality in
> > > vfs_ioc_setflags_check() (possibly renaming it to
> > > vfs_ioc_setflags_prepare() to indicate it does already some changes)? I
> > > don't see any place that would need these two separated...
> > 
> > XFS needs them to be separated.
> > 
> > If we even /think/ that we're going to be setting the immutable flag
> > then we need to grab the IOLOCK and the MMAPLOCK to prevent further
> > writes while we drain all the directio writes and dirty data.  IO
> > completions for the write draining can take the ILOCK, which means that
> > we can't have grabbed it yet.
> > 
> > Next, we grab the ILOCK so we can check the new flags against the inode
> > and then update the inode core.
> > 
> > For most filesystems I think it suffices to inode_lock and then do both,
> > though.
> 
> Heh, lol, that applies to fssetxattr, not to setflags, because xfs
> setflags implementation open-codes the relevant fssetxattr pieces.
> So for setflags we can combine both parts into a single _prepare
> function.

Yeah. Also for fssetxattr we could use the prepare helper at least for
ext4, f2fs, and btrfs where the situation isn't so complex as for xfs to
save some boilerplate code.

								Honza

> > > > +/*
> > > > + * Flush all pending IO and dirty mappings before setting S_IMMUTABLE on an
> > > > + * inode via FS_IOC_SETFLAGS.  If the flush fails we'll clear the flag before
> > > > + * returning error.
> > > > + *
> > > > + * Note: the caller should be holding i_mutex, or else be sure that
> > > > + * they have exclusive access to the inode structure.
> > > > + */
> > > > +static inline int vfs_ioc_setflags_flush_data(struct inode *inode, int flags)
> > > > +{
> > > > +	int ret;
> > > > +
> > > > +	if (!vfs_ioc_setflags_need_flush(inode, flags))
> > > > +		return 0;
> > > > +
> > > > +	inode_set_flags(inode, S_IMMUTABLE, S_IMMUTABLE);
> > > > +	ret = inode_flush_data(inode);
> > > > +	if (ret)
> > > > +		inode_set_flags(inode, 0, S_IMMUTABLE);
> > > > +	return ret;
> > > > +}
> > > 
> > > Also this sets S_IMMUTABLE whenever vfs_ioc_setflags_need_flush() returns
> > > true. That is currently the right thing but seems like a landmine waiting
> > > to trip? So I'd just drop the vfs_ioc_setflags_need_flush() abstraction to
> > > make it clear what's going on.
> > 
> > Ok.
> > 
> > --D
> > 
> > > 
> > > 								Honza
> > > -- 
> > > Jan Kara <jack@suse.com>
> > > SUSE Labs, CR
> > 
> > _______________________________________________
> > Ocfs2-devel mailing list
> > Ocfs2-devel@oss.oracle.com
> > https://oss.oracle.com/mailman/listinfo/ocfs2-devel
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

