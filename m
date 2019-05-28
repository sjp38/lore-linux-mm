Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB07DC282E5
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 03:26:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69C3220675
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 03:26:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OO5A0Ki4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69C3220675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFCB66B026E; Mon, 27 May 2019 23:26:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAC056B0270; Mon, 27 May 2019 23:26:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9C576B027A; Mon, 27 May 2019 23:26:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 733BE6B026E
	for <linux-mm@kvack.org>; Mon, 27 May 2019 23:26:41 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z2so14700236pfb.12
        for <linux-mm@kvack.org>; Mon, 27 May 2019 20:26:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QG32BojiDvTi7QyqABLSNsM9GCVly22jtOu9QTHQPrg=;
        b=UtonBWgCzc5t+0F58YnIremMxGeee43W8E8DSFfWidNmi23c0aEeTeNitlBua7SLMf
         Kvg0LffMa/1RV2aTF87Y1pX9Fgeojcs/3Vz9DHj3gu3+SYindMe8+2amR078ZOBRCMqq
         K0fAh0/2hz8R04jnRuJG0FM8C/JHpG+8EMpQqNN0Ark3eos9Yg0t9/EWiPWjM7380XKX
         6p9oSnn110ZdJEN3wh0h6PAKZZCKIyZ75juJ8mqD6yQA5MuGbaXEpstqK37cWQzH1VgX
         BoTs8H5ubFYUrXjf6SyIStQf8q78IljwhYDsDR8FSsenm2EA8qB0t3QBNvXBQfJloEEK
         9mIA==
X-Gm-Message-State: APjAAAW30Z3PXeWbA8f/eDgP7ckqoHAKRJ++ftNZXuF/AIWSe4dgwI62
	tQNASLtaCwvo4hXpUnPV+GT6Wah60SNaPtV6fo3dm46aAmd3n/Dm/c76NvQEEGwppJOJrs423qP
	3zsdc+WvFEtakfCz/67FM13ixj08LH9fyYGMLBU8fnhAwizwIr0GqNU5y6bvJpeA=
X-Received: by 2002:a17:902:163:: with SMTP id 90mr133232976plb.212.1559014000837;
        Mon, 27 May 2019 20:26:40 -0700 (PDT)
X-Received: by 2002:a17:902:163:: with SMTP id 90mr133232862plb.212.1559013999787;
        Mon, 27 May 2019 20:26:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559013999; cv=none;
        d=google.com; s=arc-20160816;
        b=USSv3LPtMSP51xqQ5t4wjLj8qx7K+wAfPaLtXWAYcG0/EOPi4pEj6XIxSsBb3NDJKJ
         xO7Q9aSiOxXT4u9F4qTnuKu6VR2uum/Ij3wMO/TT6r9Ddf6t5BdW2JumZ8Cc3AmtNJPm
         VdjTRbBe8PDiKJn8U2tHLtPc2TaajE1mqnBEZ5WvubfKnc15IYVudL84nSX/07XAyhAQ
         /j1qWwAyDWUsL265/iywfiBKyRCLph5k8mQRNI+Uhc5nVaD+ikvXTgIlS+ZOclYdd44G
         gdBfnzTmrYFq3aI+azdSSa9OZR0hkStumw3qAx1l/Z7Cf7JJUKWGoA1gLPXEykL5po7b
         T72w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=QG32BojiDvTi7QyqABLSNsM9GCVly22jtOu9QTHQPrg=;
        b=xvOG4onRdFQVcwvtSMSfgBc+BXHfMiJ9VBw651fyezQIg8jsNzHfExH2CdaGXaAiL7
         07hOnImrsLbBo+1B/sgkxD0t5CQ3LB83VjYB0drWPcUA0FYPgus49KqmuM1fShYk0QvU
         8ndFLwD2Y2F9gMpWA28rtVqob8EZVU8a9ZpMSOfmtRNG9kigXqMn7VRONi0Ki2EoVUgZ
         Uaqb/qsM92ZiF/HpNdVeUz74A3Ioj68eHrVbZk/tJLC+XGK+kDgcucFBs5925LrltP3h
         HXc/16xipXJi//zCky61eOI4Uv9WEhoaUcoAbB5AyVjnvMpOfL1gHhibnNfgvOxKpzNl
         vVcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OO5A0Ki4;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n88sor1380542pjc.26.2019.05.27.20.26.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 20:26:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OO5A0Ki4;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QG32BojiDvTi7QyqABLSNsM9GCVly22jtOu9QTHQPrg=;
        b=OO5A0Ki4+Hhg7qm9S2QddUw6ei4mfN0ziSpjQ2FJr9EwFpQOjVJZk7AXIrWdy2b8d8
         9As80BlwO/xBsRxNIMxw8LTIbaap21mfZbZsKmD1QcvQlZXPBhFWWHyRYjELMyCff5wz
         kOQ+viUNi2TU0D3OYeya1qiu+zbQnrMrSWCd+grhmCMfYHX4gSTxNui1Fmll74ErHW6r
         QxOTx9QVMsO1vig+fdYh9qNbbBRkDfpyRjjzLU4/Y3Jc0hQHkdvXHbwDJKFhdR8tcVxO
         SSM+1EjY/KSeK5kj4iihK4oBfeMh2iJbpmgY1z0TWrtkQLnTp1RgyfbwUrVy4DniOeny
         Ssjg==
X-Google-Smtp-Source: APXvYqxlMeibdgDQO1OB7jGa10I7zpitXKcUIwCKk9t9v+ZxXCrcvGIW7KcFY9Hh+mB+DsnRrbkWCw==
X-Received: by 2002:a17:90a:f98d:: with SMTP id cq13mr2713394pjb.41.1559013999141;
        Mon, 27 May 2019 20:26:39 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id q17sm18860762pfq.74.2019.05.27.20.26.34
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 27 May 2019 20:26:37 -0700 (PDT)
Date: Tue, 28 May 2019 12:26:32 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190528032632.GF6879@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-8-minchan@kernel.org>
 <20190520092801.GA6836@dhcp22.suse.cz>
 <20190521025533.GH10039@google.com>
 <20190521062628.GE32329@dhcp22.suse.cz>
 <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527124411.GC1658@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 02:44:11PM +0200, Michal Hocko wrote:
> On Mon 27-05-19 16:58:11, Minchan Kim wrote:
> > On Tue, May 21, 2019 at 08:26:28AM +0200, Michal Hocko wrote:
> > > On Tue 21-05-19 11:55:33, Minchan Kim wrote:
> > > > On Mon, May 20, 2019 at 11:28:01AM +0200, Michal Hocko wrote:
> > > > > [cc linux-api]
> > > > > 
> > > > > On Mon 20-05-19 12:52:54, Minchan Kim wrote:
> > > > > > System could have much faster swap device like zRAM. In that case, swapping
> > > > > > is extremely cheaper than file-IO on the low-end storage.
> > > > > > In this configuration, userspace could handle different strategy for each
> > > > > > kinds of vma. IOW, they want to reclaim anonymous pages by MADV_COLD
> > > > > > while it keeps file-backed pages in inactive LRU by MADV_COOL because
> > > > > > file IO is more expensive in this case so want to keep them in memory
> > > > > > until memory pressure happens.
> > > > > > 
> > > > > > To support such strategy easier, this patch introduces
> > > > > > MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER options in madvise(2) like
> > > > > > that /proc/<pid>/clear_refs already has supported same filters.
> > > > > > They are filters could be Ored with other existing hints using top two bits
> > > > > > of (int behavior).
> > > > > 
> > > > > madvise operates on top of ranges and it is quite trivial to do the
> > > > > filtering from the userspace so why do we need any additional filtering?
> > > > > 
> > > > > > Once either of them is set, the hint could affect only the interested vma
> > > > > > either anonymous or file-backed.
> > > > > > 
> > > > > > With that, user could call a process_madvise syscall simply with a entire
> > > > > > range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
> > > > > > MADV_FILE_FILTER so there is no need to call the syscall range by range.
> > > > > 
> > > > > OK, so here is the reason you want that. The immediate question is why
> > > > > cannot the monitor do the filtering from the userspace. Slightly more
> > > > > work, all right, but less of an API to expose and that itself is a
> > > > > strong argument against.
> > > > 
> > > > What I should do if we don't have such filter option is to enumerate all of
> > > > vma via /proc/<pid>/maps and then parse every ranges and inode from string,
> > > > which would be painful for 2000+ vmas.
> > > 
> > > Painful is not an argument to add a new user API. If the existing API
> > > suits the purpose then it should be used. If it is not usable, we can
> > > think of a different way.
> > 
> > I measured 1568 vma parsing overhead of /proc/<pid>/maps in ARM64 modern
> > mobile CPU. It takes 60ms and 185ms on big cores depending on cpu governor.
> > It's never trivial.
> 
> This is not the only option. Have you tried to simply use
> /proc/<pid>/map_files interface? This will provide you with all the file
> backed mappings.

I compared maps vs. map_files with 3036 file-backed vma.
Test scenario is to dump all of vmas of the process and parse address
ranges.
For map_files, it's easy to parse each address range because directory name
itself is range. However, in case of maps, I need to parse each range
line by line so need to scan all of lines.

(maps cover additional non-file-backed vmas so nr_vma is a little bigger)

performance mode:
map_files: nr_vma 3036 usec 13387
maps     : nr_vma 3078 usec 12923

powersave mode:

map_files: nr_vma 3036 usec 52614
maps     : nr_vma 3078 usec 41089

map_files is slower than maps if we dump all of vmas. I guess directory
operation needs much more jobs(e.g., dentry lookup, instantiation)
compared to maps.

