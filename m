Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98A4CC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:28:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57B45217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:28:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57B45217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E24398E0002; Tue, 12 Feb 2019 11:28:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD4AB8E0001; Tue, 12 Feb 2019 11:28:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC2BC8E0002; Tue, 12 Feb 2019 11:28:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 754EC8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:28:35 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d62so2657973edd.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:28:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ukxr7fjPorI1dRNVvJhpr/xC2RQ+hd6fk1EhheYEpDw=;
        b=JAFD3ARmYX0NTkSntY7tZLb0TQ2cM+U2LtnTJ3zJ9lTJtTdQjNxY2J1icCd+sN3+Ok
         0prrlwictMT5t+MscaciGaAJqh706Sd7aNIT3XyxiJ+WGDx3JR/Tppr0L1fe/WAQsqNx
         knujztCWIfnhWi4IhCXVLQX/bkW292bLFTsJxE/J1D+5lrZgCS0AOhKNNmvnS0ecO/kC
         fkWJhBtWRh2UrO4uJz0Yyzwha/bRbF282sB1ZPv/imoG5kNNI+nAKrtGvIaEm9/wkuOH
         yTT+j2SDyjIqXVlo5gkU7bef4qBYI+hzacZYqsZL68SI4atCWYwAvIDE5PFp3VOXl0TH
         Pc8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAualZ5D43Sc/aTPpRTauqgewGR3tg491tdyOOLAlNbf+WlxOzPwk
	VSz5mkPpDQlh7u2ViWA6l+zcCF0gjlFeOWGcIXqc3CEy8H5+VAZJhI8Lju5AnUHNYdFO3xDgiUE
	TQBgzYDWYtlfX9h7R+hwmHEJiRJibLFpy3O4641kdgRtLoud6JzgIy3WeJGOAn9IsnQ==
X-Received: by 2002:a17:906:1248:: with SMTP id u8mr3357467eja.33.1549988915012;
        Tue, 12 Feb 2019 08:28:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaC0lZSl1A8O+JeLLQ9XGAu4PaFyZXKPmmCtJr2nPBsDxWOt5bpdtUOyyW62QSwsLMPjGAl
X-Received: by 2002:a17:906:1248:: with SMTP id u8mr3357409eja.33.1549988914077;
        Tue, 12 Feb 2019 08:28:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549988914; cv=none;
        d=google.com; s=arc-20160816;
        b=wbzdq7BdfN+WK29ZZFH4/jCshT4UM2emEx/uhAoeuGSlrDJXo3SfmozE3o62EX9TSs
         tHNdyWSSOCnfZwUchTMEV5lwuuQz5DSfhuBG8lave+SI1ze1+NF0roenq0+qpxuIS6jy
         p1CaDnI31WvaNQKPG0TX1d2Vtnl1uuVhgIN6Rl8tnGTBnqDrhxvOgQgTVSVl5a6tQIKT
         a++s0EOhf4qfM4iY6rPUjPQ9llSs5cRB9veik8vY4D2aTMW95ODDNO+ulWguEfq1WUMi
         KDBtVri61sowSEOVfjUdL7OM2TYzaLv9rVECC7CNceJZPUpgBHMcWPQQnJAHJK/y918U
         lNsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ukxr7fjPorI1dRNVvJhpr/xC2RQ+hd6fk1EhheYEpDw=;
        b=ZukKsRcrSXqMqvs9hrNUNrcCsIDU0m7GhE+TianFQTN80op0tmZgg9dp+mCDtgrDrA
         xfWlB/3Bkw4fY5/fSb8jE8wlIUcdbihYTtXL2xXFm2SnUosTMM+cNywqYUpYD7KuJhoS
         2KTtqidb7uKRbRWVCUGy0iCEMtJ+lys9KaTeIMSmDZYiJWRCdpl8oFOwE+6XueBgD7TX
         E4czyaPdMmxUt3ayP4UxLtbqR9FeTxCpSmLRNfBYUQDjSjKTGAS63rJPLTiKkH9I+L3K
         f8axKRRJf5/pSohw8yJEnk0IxS7X+1WqZyTKjfFIiCAmSEqftCVqYiaF9Wo38fwIonUM
         j+bA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x9si3221516ejn.55.2019.02.12.08.28.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:28:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 38887B60F;
	Tue, 12 Feb 2019 16:28:33 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 904741E09C5; Tue, 12 Feb 2019 17:28:32 +0100 (CET)
Date: Tue, 12 Feb 2019 17:28:32 +0100
From: Jan Kara <jack@suse.cz>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190212162832.GC19076@quack2.suse.cz>
References: <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211180654.GB24692@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-02-19 11:06:54, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 09:22:58AM -0800, Dan Williams wrote:
> 
> > I honestly don't like the idea that random subsystems can pin down
> > file blocks as a side effect of gup on the result of mmap. Recall that
> > it's not just RDMA that wants this guarantee. It seems safer to have
> > the file be in an explicit block-allocation-immutable-mode so that the
> > fallocate man page can describe this error case. Otherwise how would
> > you describe the scenarios under which FALLOC_FL_PUNCH_HOLE fails?
> 
> I rather liked CL's version of this - ftruncate/etc is simply racing
> with a parallel pwrite - and it doesn't fail.

The problem is page pins are not really like pwrite(). They are more like
mmap access. And that will just SIGBUS after truncate. So from user point
of view I agree the result may not be that surprising (it would seem just
as if somebody did additional pwrite) but from filesystem point of view it
is very different and it would mean a special handling in lots of places.
So I think that locking down the file before allowing gup_longterm() looks
like a more viable alternative.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

