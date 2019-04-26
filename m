Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D125BC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 06:28:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98EE3206BA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 06:28:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98EE3206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 291E26B0005; Fri, 26 Apr 2019 02:28:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 240ED6B0006; Fri, 26 Apr 2019 02:28:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 157796B0007; Fri, 26 Apr 2019 02:28:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1C126B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 02:28:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id ba11so1325333plb.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 23:28:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GM/AyfiDdVPnH6Ntvyi8pR1gr2NlYEpRMclicwXOzxo=;
        b=faWpfXD6r5/+AU6G53xMzXA9WlvPMn2l+BPMXBzS0noZwhubq3WKYuYFcHhpsfeQJs
         5vy1E4r9nSf+7RmusUl2/qdiLOt9/a7TwKv8OGhD8hDS5ZG/0G9TOtulEoHBoQnVoCdC
         jKUxIym+/b0pqf6PWdBQeIz53415hCm8JMScCbUgxJDNlCKhU/4IXCc6WZT5vgKP6Bfe
         LCfMPltd75y85Di0OmIiIZgKvo7cdR9LVVJkAU+9aCyB/dO8HYaH5zpnCX+oHgh83nd4
         pnfZUciXlNAq/QfTGhxZg4VZ4mT6Lbi9f2CbQFsjEswWd7t6zyhwj6sLeFA1RQzSCJUb
         9jng==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXnWsoYqzv5eeByKVVwQ3nXpL5nMeRsedQl40tDR7hiKcXatQ4O
	SjNq61q4OXop6KhKE4p/YgxdQasfi4HYOgPduebZDQoNhMqMtHmu/jaBmbsVmFEeW9dLrVxLjf9
	kbdEivAp0xMFjB7IGrTa/xQq4phMASfL/+ZkTcWOtiEXhAiATxTnLbcRcBc/HVoY=
X-Received: by 2002:a17:902:2907:: with SMTP id g7mr44227291plb.238.1556260102490;
        Thu, 25 Apr 2019 23:28:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuf369FOFpOvY15yv5+1nXt2VT94tvra/aMWXY4nC2TOjgrlgHu8cAuIrNPbbr5F/3o8ss
X-Received: by 2002:a17:902:2907:: with SMTP id g7mr44227230plb.238.1556260101515;
        Thu, 25 Apr 2019 23:28:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556260101; cv=none;
        d=google.com; s=arc-20160816;
        b=bYitpIK1ZJXPfTO54hnD1+s8ml8SSUjotN/ky+9b0HsTsrbpxcSj8y8eny77oWWpXA
         j+bxSKJnAd1cfCNHqMKovrShcG6UbvV7XDJ8BaqZ1+3RbeXVLu4K4NLQ8JowUAyBKNnK
         6POVV7vDMErbfcci4S/IRvv9djEU7cHTpmBEaz4GJ9vb41Dy2jbrPbbP5gtE9ZrlM9/S
         I+JlnKY3APgNxlMf0gZA6Z0N/wpgZq2kdAohnkI1MN1SpUbS6ex0OTLZWC3MGqb8Ps2O
         wfVMSAp2En0/loD3ypNYNW29LG+LO7Wltr3r59XU9evhoxEnoUh4oqTW9M8UKOsGorhM
         S2bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GM/AyfiDdVPnH6Ntvyi8pR1gr2NlYEpRMclicwXOzxo=;
        b=gy3CsqpjoEoDt2FetelYNo0GbB9yTd73O2yY2goFvxK0A9kebxKx7lUHiMGd692yfT
         aSSh9VvZ9JWMYBvkh7qRoqcSVP48auad6BkE8nc/ota89jR+7xScxNE+4ssQvDq3ZsaJ
         Em8LhI3HgNCKTGkD8YdL71yW4cVqU/+eKHSLU7vawPMoonuqxtKVko1VH+pB/dT0zRPr
         WOp7+sTYk+N2pQUWA99CCIfC9v4RS47QfjfBukcNPMpYoGcCjlB585aCTR6devZJZuaB
         IViCOXPnu7tqZ6JIjGICF5qd6fxL9uL1V/tjJd/iXeXXJYrE0ztXboAaSdwgQbIh8EZY
         5Pkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id n7si4421985pga.446.2019.04.25.23.28.20
        for <linux-mm@kvack.org>;
        Thu, 25 Apr 2019 23:28:21 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-171-240.pa.nsw.optusnet.com.au [49.181.171.240])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 8E06D43C0BA;
	Fri, 26 Apr 2019 16:28:18 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hJuLJ-0006GU-0F; Fri, 26 Apr 2019 16:28:17 +1000
Date: Fri, 26 Apr 2019 16:28:16 +1000
From: Dave Chinner <david@fromorbit.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Direct block mapping through fs for device
Message-ID: <20190426062816.GG1454@dread.disaster.area>
References: <20190426013814.GB3350@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426013814.GB3350@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=LhzQONXuMOhFZtk4TmSJIw==:117 a=LhzQONXuMOhFZtk4TmSJIw==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=oexKYjalfGEA:10
	a=7-415B0cAAAA:8 a=VUkQmcHZEWhioDgAkr4A:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 09:38:14PM -0400, Jerome Glisse wrote:
> I see that they are still empty spot in LSF/MM schedule so i would like to
> have a discussion on allowing direct block mapping of file for devices (nic,
> gpu, fpga, ...). This is mm, fs and block discussion, thought the mm side
> is pretty light ie only adding 2 callback to vm_operations_struct:

The filesystem already has infrastructure for the bits it needs to
provide. They are called file layout leases (how many times do I
have to keep telling people this!), and what you do with the lease
for the LBA range the filesystem maps for you is then something you
can negotiate with the underlying block device.

i.e. go look at how xfs_pnfs.c works to hand out block mappings to
remote pNFS clients so they can directly access the underlying
storage. Basically, anyone wanting to map blocks needs a file layout
lease and then to manage the filesystem state over that range via
these methods in the struct export_operations:

        int (*get_uuid)(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
        int (*map_blocks)(struct inode *inode, loff_t offset,
                          u64 len, struct iomap *iomap,
                          bool write, u32 *device_generation);
        int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
                             int nr_iomaps, struct iattr *iattr);

Basically, before you read/write data, you map the blocks. if you've
written data, then you need to commit the blocks (i.e. tell the fs
they've been written to).

The iomap will give you a contiguous LBA range and the block device
they belong to, and you can then use that to whatever smart DMA stuff
you need to do through the block device directly.

If the filesystem wants the space back (e.g. because truncate) then
the lease will be revoked. The client then must finish off it's
outstanding operations, commit them and release the lease. To access
the file range again, it must renew the lease and remap the file
through ->map_blocks....

> So i would like to gather people feedback on general approach and few things
> like:
>     - Do block device need to be able to invalidate such mapping too ?
> 
>       It is easy for fs the to invalidate as it can walk file mappings
>       but block device do not know about file.

If you are needing the block device to invalidate filesystem level
information, then your model is all wrong.

>     - Do we want to provide some generic implementation to share accross
>       fs ?

We already have a generic interface, filesystems other than XFS will
need to implement them.

>     - Maybe some share helpers for block devices that could track file
>       corresponding to peer mapping ?

If the application hasn't supplied the peer with the file it needs
to access, get a lease from and then map an LBA range out of, then
you are doing it all wrong.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

