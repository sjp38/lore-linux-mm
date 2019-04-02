Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FF30C43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:45:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAD8F2075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:45:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAD8F2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7C8A6B0010; Tue,  2 Apr 2019 03:45:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2B746B0266; Tue,  2 Apr 2019 03:45:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF3736B0269; Tue,  2 Apr 2019 03:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 843E06B0010
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 03:45:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h27so5379859eda.8
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 00:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3cI4nRXXEW62VDrez+fhfmTQ9J1h3P0LWV3X7lB/4tE=;
        b=Pv4BX0W3DxpHnzDbMXrDrenXbRNayu7Wvdn8t4CrCjIjZZ8kJpcgUgIjWpdhT7Wblx
         T99rz95bFiS9FQgyzDSe7tqgQDO3NXQn+idJNYumb3izKIZGbKG0uYMYfk/qldfBomSP
         mIWCprlASVafAzJroHRmnXC8JaZokKK8bWON5sif+t+aXyjZbVWMh/ALpwcz8X0mml9N
         jfq1DuO/UrSbVNvg+85OCFOMB0Reouda3RP9K233Sy7UhRC3guDJiP4eqd7mI6R4MFWq
         0ykuIpD73aWXhMRfOes5m0kKIHoMSH/xRH/e4IbRKjDdF1LsRtYpc5cbGOdIReax0YCW
         H6Sg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAVmrfylLNgelOfMyWUOFvOd+9FoXW83AXa+b+9tsAcUz062QTjw
	YuixThMoGHFoFK+0ShlOJvlJKhsOKd0NAOdlzHmrsMgYGGay163nAur9BNG4VI6cGB4nqiiZrlq
	mQ3bjieG+1di35aUV+xaifpHbPcA8HVZFWJkYNgLK7UVsg7mnFXg9tap69jlpbdykPg==
X-Received: by 2002:a50:89fb:: with SMTP id h56mr44066997edh.176.1554191103085;
        Tue, 02 Apr 2019 00:45:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzq36iFd3TbGhbdmflebD3Mjen3OJSJ7gpAC+gPbMrqgDYD9zD41BgW5iE6lgaQNeO/+eRU
X-Received: by 2002:a50:89fb:: with SMTP id h56mr44066969edh.176.1554191102373;
        Tue, 02 Apr 2019 00:45:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554191102; cv=none;
        d=google.com; s=arc-20160816;
        b=QfJ4s6b7ZSkOauergOMSXdniP+qi1wfvdnG9CgsgPixUt7+0oOLUIf0h78jVaaJTni
         fkNovcw2EsbXmhYaM73ErQZscWusAxbwm2971VzIdbJ5srGfhY6bkh4GedOCwH4lLJ5H
         zlZYPXCMILBoraF5V6CvQzXOAAkjw1J+HpwiLCnxld48291hiBXok4/zkJWOHaUAgdes
         JJNE18oPQ4miFp03G3Sin54gCLgW5s4kxbziuAgTQ7INMnxmTf1CbBvW+kfEOHmmCOaO
         UdfbP5zcS3FrP9aOQOzDhkn4M8dnfaClo3Dp4hIIJWms+XPvrb+/Yuj0Vcn8g5jC/eWM
         0iTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3cI4nRXXEW62VDrez+fhfmTQ9J1h3P0LWV3X7lB/4tE=;
        b=Pqvp8674It81yVlWXljIPCJ7SM3vtIRNG+z4DexSc3Q4yNt6xyWNBPiRwmdYRqRaD5
         Vgbb5PlSqCU49vSxJEVq8l+GBf1FTDTelFc2ndPeM2chi2Ys1SRSihe6l08yGpKct0o0
         jqq+gP1BNqBtnqDSg9UfQm2LCBB4ZUiL3YIHHV5p8BWlZtdliZo3esfnm3s7C4BeMDAc
         J/1xmmMRn1DKO68VuSDxlSdabsRebjtebsHmTk7IS0r3/pyrNbrDp5jiH/rVrv9apd35
         JRvjTso1JgECj45g+pVrJ+13Jc/00Y5f3ktUJGwmOnSSfroBxyQinFHu6ksGH7Z1VCFM
         ++Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y22si43252edc.134.2019.04.02.00.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 00:45:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DD45AABF5;
	Tue,  2 Apr 2019 07:45:01 +0000 (UTC)
Date: Tue, 2 Apr 2019 09:44:59 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: willy@infradead.org, Jan Kara <jack@suse.cz>,
	Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH] mm: add vm event for page cache miss
Message-ID: <20190402074459.GP28293@dhcp22.suse.cz>
References: <1554185720-26404-1-git-send-email-laoar.shao@gmail.com>
 <20190402072351.GN28293@dhcp22.suse.cz>
 <CALOAHbASRo1xdkG62K3sAAYbApD5yTt6GEnCAZo1ZSop=ORj6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbASRo1xdkG62K3sAAYbApD5yTt6GEnCAZo1ZSop=ORj6w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-04-19 15:38:02, Yafang Shao wrote:
> On Tue, Apr 2, 2019 at 3:23 PM Michal Hocko <mhocko@suse.com> wrote:
> >
> > On Tue 02-04-19 14:15:20, Yafang Shao wrote:
> > > We found that some latency spike was caused by page cache miss on our
> > > database server.
> > > So we decide to measure the page cache miss.
> > > Currently the kernel is lack of this facility for measuring it.
> >
> > What are you going to use this information for?
> >
> 
> With this counter, we can monitor pgcachemiss per second and this can
> give us some informaton that
> whether the database performance issue is releated with pgcachemiss.
> For example, if this value increase suddently, it always cause latency spike.
> 
> What's more, I also want to measure how long this page cache miss may cause,
> but this seems more complex to implement.

Aren't tracepoints a better fit with this usecase? You not only get the
count of misses but also the latency. Btw. latency might be caused also
for the minor fault when you hit lock contention.
> 
> 
> > > This patch introduces a new vm counter PGCACHEMISS for this purpose.
> > > This counter will be incremented in bellow scenario,
> > > - page cache miss in generic file read routine
> > > - read access page cache miss in mmap
> > > - read access page cache miss in swapin
> > >
> > > NB, readahead routine is not counted because it won't stall the
> > > application directly.
> >
> > Doesn't this partially open the side channel we have closed for mincore
> > just recently?
> >
> 
> Seems I missed this dicussion.
> Could you pls. give a reference to it?

The long thread starts here http://lkml.kernel.org/r/nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm
-- 
Michal Hocko
SUSE Labs

