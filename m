Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24D83C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 04:27:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0F3722387
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 04:27:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GGLOY4Lh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0F3722387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 725616B000D; Tue,  4 Jun 2019 00:27:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D6B16B0266; Tue,  4 Jun 2019 00:27:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 575DB6B0269; Tue,  4 Jun 2019 00:27:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 20BB96B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 00:27:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so15230625pff.11
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 21:27:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5ghW7vZxtD9TEM+qgoDG0MODtbI6VDLCCfPNHey69jA=;
        b=Y1vmDgWoXJQK1E44zR6q88uU8JbztXiFff2PoQ3mBqYDVyerz7lPUF9muAIueu54tE
         Nx4ityfdQ+XWkHPfuU5zYUyDQGOtHdtTgzqxafw20TFBUX8mALM3H23FZXBGLahdNAbD
         bIUtUS2zL9flqhtRm+qoi4SoJ+JEyyqUtsyFjDBCAPswopiy1hNiZVHa5NLnd5rkgSKr
         Opz686Eys3xijOJi4J0a17fI3r6dN4y7M/Tb0KSbnEC3ttNZn9UrIeEV3HQ51hrIBsc3
         1a1nDEHccX8DsZhq6H81ied8WUqfNGhf9UTZHJVBiWuHPQuHmtTmve9aGpa27tqVxlIg
         dQAA==
X-Gm-Message-State: APjAAAXZIbpxymHbMRRB4SCKVXmO1UC4X/xoxPMi6GiffFKtRmreOqb0
	pEQK4ee7gTEIVrIrwvf7hraArI+vuanpTLrJzXEmB0HiSDi8JoTsH2o1x8zfwXbtcko2sPnDzXn
	WRlbpWNQFgpXC3h8DN6a1BNo3hHQOFB27OvEFqMgizjZXf5/b3DVarBz17o6+ISI=
X-Received: by 2002:a65:6398:: with SMTP id h24mr20096255pgv.446.1559622420662;
        Mon, 03 Jun 2019 21:27:00 -0700 (PDT)
X-Received: by 2002:a65:6398:: with SMTP id h24mr20096213pgv.446.1559622419719;
        Mon, 03 Jun 2019 21:26:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559622419; cv=none;
        d=google.com; s=arc-20160816;
        b=FO/18R9Vg6gmcem5VMb6ZERS16frcbcrlveSnn09Q7rcQbRlnQghpnjhS9fLR4f0tx
         FPYewPQ8kVBbimxYvlzzF24kGJn+/tPhp87Gt56JNnLhNMq/QCpMlPFpV8/2dcTkKMzM
         zBb7Q9rFjRykQEg5QD5pD33ZM6klHv+Oo+7twt0Hs1nvVzp1XzpPI5MH+Q/E+6DK3pmE
         32HPRFPlcR13Rg4QjYPmiZmKFxtejAGj3PyFv+EaNRFrnZVYSuuJPDrOjfMrRcaHJ41C
         nGR0Y5T32BPoDtG1fPin/BY8Sm1WBNxuxJtbz5cqPBwx3fTbhOVgAPcHn9WSwUyOWX8Q
         Rw/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=5ghW7vZxtD9TEM+qgoDG0MODtbI6VDLCCfPNHey69jA=;
        b=wrFd+GvDPj+LWurPThEDcPgxqXfDZYyDhguw1XuMshaIJS/IyLmGgHJ5SBjqLFV+OZ
         GP5l4/60/WcmkOVJ3T9j7XUEEsH85H14Zw0c4UvxXp2jkWUPEM+8s2TRgn5D+1OxiQIH
         HmVR0SgMrxi309vd81kWQo6rZtgp5ysFFA9ur2s2annqbiKGdxJPaNjtW/zsm9fHXSG9
         ACZXpwuTJt6ud9DTf25UXfdo2Vf4WNSvRZgfcTZzpDhfa2EIgZ9EaDjIzwmwoWQqT2I3
         WV3ceE+pKXeazCdcyeQ5XN2MbPUMyvdSvPFrNTvJoogos0GF5MlrZZY2V29w8onCPBqr
         bj6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GGLOY4Lh;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor17290246pgh.12.2019.06.03.21.26.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 21:26:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GGLOY4Lh;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=5ghW7vZxtD9TEM+qgoDG0MODtbI6VDLCCfPNHey69jA=;
        b=GGLOY4Lh3Uc5kASC5eWRsdjBzWNIdVe64631KWVwKmllcALTogaSgWf1MfDyArRuto
         SY0qwlS9eNnEro/DclKyuFoVITC030558nEHdOsh8EPAvnas61psi+E06QK9wsQdwscy
         9jrOP9iCsqxqKVvMAZb9jxOaw/PqtjOubFI50yvxBoTtP0wa75b0Gqqv13b7hT5UsbUZ
         +Vi0h1EFkIcPi4aIDl4Fb2SLlJRRe1VImbiK5lnjdJ/kmQMwFDPBztoan5MFomGDORfT
         OtDoC9ekgw8rFKXJQQEyFzvKYwwZZitO6Ov83a0yn8GzO3F5hVHoEvfJ3YoM0p1wxef0
         mfWg==
X-Google-Smtp-Source: APXvYqxAEyGDKuJIqda0JeMfwT8/ZDr6kjeGAWrJ14wxIzxTTOjbDVn6f7FM0zC8JcZTmxqn6bLclA==
X-Received: by 2002:a63:e10d:: with SMTP id z13mr11914157pgh.116.1559622419276;
        Mon, 03 Jun 2019 21:26:59 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id m11sm13287492pjv.21.2019.06.03.21.26.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 03 Jun 2019 21:26:58 -0700 (PDT)
Date: Tue, 4 Jun 2019 13:26:51 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
Message-ID: <20190604042651.GC43390@google.com>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
 <20190531133904.GC195463@google.com>
 <20190531140332.GT6896@dhcp22.suse.cz>
 <20190531143407.GB216592@google.com>
 <20190603071607.GB4531@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603071607.GB4531@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 09:16:07AM +0200, Michal Hocko wrote:
> On Fri 31-05-19 23:34:07, Minchan Kim wrote:
> > On Fri, May 31, 2019 at 04:03:32PM +0200, Michal Hocko wrote:
> > > On Fri 31-05-19 22:39:04, Minchan Kim wrote:
> > > > On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> > > > > On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > > > > > When a process expects no accesses to a certain memory range, it could
> > > > > > give a hint to kernel that the pages can be reclaimed when memory pressure
> > > > > > happens but data should be preserved for future use.  This could reduce
> > > > > > workingset eviction so it ends up increasing performance.
> > > > > > 
> > > > > > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > > > > > MADV_COLD can be used by a process to mark a memory range as not expected
> > > > > > to be used in the near future. The hint can help kernel in deciding which
> > > > > > pages to evict early during memory pressure.
> > > > > > 
> > > > > > Internally, it works via deactivating pages from active list to inactive's
> > > > > > head if the page is private because inactive list could be full of
> > > > > > used-once pages which are first candidate for the reclaiming and that's a
> > > > > > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > > > > > if the memory pressure happens, they will be reclaimed earlier than other
> > > > > > active pages unless there is no access until the time.
> > > > > 
> > > > > [I am intentionally not looking at the implementation because below
> > > > > points should be clear from the changelog - sorry about nagging ;)]
> > > > > 
> > > > > What kind of pages can be deactivated? Anonymous/File backed.
> > > > > Private/shared? If shared, are there any restrictions?
> > > > 
> > > > Both file and private pages could be deactived from each active LRU
> > > > to each inactive LRU if the page has one map_count. In other words,
> > > > 
> > > >     if (page_mapcount(page) <= 1)
> > > >         deactivate_page(page);
> > > 
> > > Why do we restrict to pages that are single mapped?
> > 
> > Because page table in one of process shared the page would have access bit
> > so finally we couldn't reclaim the page. The more process it is shared,
> > the more fail to reclaim.
> 
> So what? In other words why should it be restricted solely based on the
> map count. I can see a reason to restrict based on the access
> permissions because we do not want to simplify all sorts of side channel
> attacks but memory reclaim is capable of reclaiming shared pages and so
> far I haven't heard any sound argument why madvise should skip those.
> Again if there are any reasons, then document them in the changelog.

I will go with removing the part so that defer to decision to the VM reclaim
based on the review.

>  
> [...]
> 
> > > Please document this, if this is really a desirable semantic because
> > > then you have the same set of problems as we've had with the early
> > > MADV_FREE implementation mentioned above.
> > 
> > IIRC, the problem of MADV_FREE was that we couldn't discard freeable
> > pages because VM never scan anonymous LRU with swapless system.
> > However, it's not the our case because we should reclaim them, not
> > discarding.
> 
> Right. But there is still the page cache reclaim. Is it expected that
> an explicitly cold memory doesn't get reclaimed because we have a
> sufficient amount of page cache (a very common case) and we never age
> anonymous memory because of that?

If there are lots of used-once pages in file-LRU, I think there is no
need to reclaim anonymous pages because it needs bigger overhead due to
IO. It has been true for a long time in current VM policy.

Reclaim preference model based on hints is as following based on cost:

MADV_DONTNEED >> MADV_PAGEOUT > used-once pages > MADV_FREE >= MADV_COLD

It is desirable for the new hints to be placed in the reclaiming preference
order such that a) they don't overlap functionally with existing hints and
b) we have a balanced ordering of disruptive and non-disruptive hints.

