Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D15EEC282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:33:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D95021773
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:33:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20150623.gappssmtp.com header.i=@toxicpanda-com.20150623.gappssmtp.com header.b="n4kLctD7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D95021773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25ACD8E016B; Mon, 11 Feb 2019 16:33:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 209248E0165; Mon, 11 Feb 2019 16:33:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F8FE8E016B; Mon, 11 Feb 2019 16:33:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id D14468E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:33:55 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id i2so296619ywb.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:33:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hVKwAqoHVFgMa2AWbKba1qi0i0vrDDmcwy0nd3S4ZKE=;
        b=m6H+DDO4tFIHMoJN0/p64H8J1VAV7LgoVx7fCDDEOji8ISYJ0T0itqSgdhOWZ1/n9u
         NuT87p4C+42mi+x5dOPObgPfRbXsk3qwpOM9fjQG72JQLHxTDoWrndPc5sbPfwM+/hvX
         YrLNna7/d+IP37Swm2vpoCf6FJyWrlQDPmbH5K60ri+5nbkwT3nSfQ2ir69As/zd/6tV
         p6xYqAnHA/aZ+7+l0SQNlcviF1Dr8RIIFcIFj4L4pXooM5/2Kp8eZiV1aIOLga+FGuRu
         MOLRmanrVZuCNKrrHHWiMvXVz0S4v+F1ioQu+3CQV/AlnHsfZB8ZCtimkfQtY8xpjfNs
         0Pyg==
X-Gm-Message-State: AHQUAuYCz8L8bOmcm6xBSdT9v/GW4y//CSIWDFqcDJxGLIOxUG3s2Y3T
	J6OFKAOwOvU8RigrG7pCIS63V/XmUfwxSDkY8SvaAuAZj6J2yxTzVZXiPHUDDnS8PyhYnr6YkYQ
	nxa/OjzVStA6ZhLCvvuhZ6QXvJQKp+wtpZ2rxgtTCZGvGs+EsxwuKmzbWDs1VPggPd6RvA8AB2K
	JYsk9iQN+M8uC3IbByjfb607Gwpm0CkoYii7q+OZ275poQXj+D2LXqfINXIQnRdO01CCdYj6/+7
	7K+nYD+r4plIH2NdO1SIiddFD3FDWRsQau6/x6to/mmFOJUk60XeFIq/F3UWLhjPJ1KsN0m2+li
	M8ipXLT/60n/yXm2Sf8geJM+aFi1k42SPNVCEQ/jCMlthNMVkuUbQbYbxqBuoZI6ssVpCZG4/6w
	u
X-Received: by 2002:a25:f301:: with SMTP id c1mr240180ybs.137.1549920835442;
        Mon, 11 Feb 2019 13:33:55 -0800 (PST)
X-Received: by 2002:a25:f301:: with SMTP id c1mr240138ybs.137.1549920834754;
        Mon, 11 Feb 2019 13:33:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549920834; cv=none;
        d=google.com; s=arc-20160816;
        b=rDoYfg9QwEmRLeJ15AE8QJKATPB8sbbH6kdZkgw5nv589FiNrU1HdnpJVRKukXiXkU
         o6sG1iomTs+c5AVZaaGgRCNTnY7Y/fL+iTAnt4x7mTrzO9dsgn6KM/jltBtKNdXwptBR
         MjCh5g3d+/rhjBnyQs+YJEbGy/MQtaOdZLXYufiOhJTRJ6F6o7I3X5UgYtam8cXbYYl5
         EuspXDZinr6e3Y+V97tBzvlNIgJ69QkXf+2YxDiwvyT+nJ5zzhjGKwuG/z/uikfmn/GH
         8WF1b9H4R3EJZKBjsDrR94hqsyXyY5KT4w8lmR0lSI6ilaYWQU9xTolycJpcCn+RCGoq
         VYeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hVKwAqoHVFgMa2AWbKba1qi0i0vrDDmcwy0nd3S4ZKE=;
        b=PDX1RhIPBAbQOEXSeQG14Ch9WdWzK5jT5xp0eSk1eORRWymcx39jcaeu17wylRghPK
         sg6Oh6qXf9YJeDw7my8QzW09uIpuAjLHZjOFvxo7gdwOE/HK3sLY4+KY0BEDOdsaxgI2
         wtCgrsPZq5eBPBZoK8CRznf2ZAjpCPFjRWmayIcyDHRfKNiBVqrzOmpofP+T+fgAyMx5
         qV5ewuCLHqPa0p7MC0aiYGkUGBekF3cBgbX6L2+fLyBIGa8SIHMyBtKI+1LprSbSKduJ
         q7n5CeckL1S1TMxC1bxyZtV9rsw0sXy5E4PkEJzaAjyFFuiEttyzRfUHeKWllZDRGk/d
         Tetw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=n4kLctD7;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17sor1244985ywh.82.2019.02.11.13.33.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 13:33:54 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=n4kLctD7;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hVKwAqoHVFgMa2AWbKba1qi0i0vrDDmcwy0nd3S4ZKE=;
        b=n4kLctD7UE5F10ODXcqZ39+kzrDLdbwMD/i67pe02a+359+Umq6pnwTJxeC682tS0I
         DMwKL3L153uyB0BH8cvIlBADZ3lTY7S1EQfotC+bLPGgmtetWYD+UumpJZSpgLQhqSo2
         8nYsYOJQ41/OkZSt4eRCegqlBeGQWMA4PW+FYjDueMH/uRS853aNPooWC57pxrU/2RBm
         R1pHvY+LRehia/wmB9yRGoXGDUq1Nr1TxgSsHro9uaYwenJ/P5pjqiDiVWHtCrhJ6DF0
         +OKywYzSNvOJIeLEXL8HofmqrDSBmWrcFd+3M9exT9kFuM30WqqtjPEZDNLrq4k6K274
         SaAA==
X-Google-Smtp-Source: AHgI3IZkTOaPIPYvC/IjGg93vPO/9Q0dSZWzvla0ANEDBJAYR5//2lx61kELPsB6crIwDeBWDynCqA==
X-Received: by 2002:a0d:d58d:: with SMTP id x135mr248358ywd.488.1549920834359;
        Mon, 11 Feb 2019 13:33:54 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:67a5])
        by smtp.gmail.com with ESMTPSA id o4sm1571505ywe.102.2019.02.11.13.33.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:33:53 -0800 (PST)
Date: Mon, 11 Feb 2019 16:34:19 -0500
From: Josef Bacik <josef@toxicpanda.com>
To: Andrea Righi <righi.andrea@gmail.com>
Cc: Josef Bacik <josef@toxicpanda.com>,
	Paolo Valente <paolo.valente@linaro.org>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Jens Axboe <axboe@kernel.dk>, Vivek Goyal <vgoyal@redhat.com>,
	Dennis Zhou <dennis@kernel.org>, cgroups@vger.kernel.org,
	linux-block@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v2] blkcg: prevent priority inversion problem during
 sync()
Message-ID: <20190211213417.uhfiz5iqwkfrvk25@macbook-pro-91.dhcp.thefacebook.com>
References: <20190209140749.GB1910@xps-13>
 <20190211153933.p26pu5jmbmisbkos@macbook-pro-91.dhcp.thefacebook.com>
 <20190211204029.GB1520@xps-13>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211204029.GB1520@xps-13>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 09:40:29PM +0100, Andrea Righi wrote:
> On Mon, Feb 11, 2019 at 10:39:34AM -0500, Josef Bacik wrote:
> > On Sat, Feb 09, 2019 at 03:07:49PM +0100, Andrea Righi wrote:
> > > This is an attempt to mitigate the priority inversion problem of a
> > > high-priority blkcg issuing a sync() and being forced to wait the
> > > completion of all the writeback I/O generated by any other low-priority
> > > blkcg, causing massive latencies to processes that shouldn't be
> > > I/O-throttled at all.
> > > 
> > > The idea is to save a list of blkcg's that are waiting for writeback:
> > > every time a sync() is executed the current blkcg is added to the list.
> > > 
> > > Then, when I/O is throttled, if there's a blkcg waiting for writeback
> > > different than the current blkcg, no throttling is applied (we can
> > > probably refine this logic later, i.e., a better policy could be to
> > > adjust the throttling I/O rate using the blkcg with the highest speed
> > > from the list of waiters - priority inheritance, kinda).
> > > 
> > > This topic has been discussed here:
> > > https://lwn.net/ml/cgroups/20190118103127.325-1-righi.andrea@gmail.com/
> > > 
> > > But we didn't come up with any definitive solution.
> > > 
> > > This patch is not a definitive solution either, but it's an attempt to
> > > continue addressing this issue and handling the priority inversion
> > > problem with sync() in a better way.
> > > 
> > > Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
> > 
> > Talked with Tejun about this some and we agreed the following is probably the
> > best way forward
> 
> First of all thanks for the update!
> 
> > 
> > 1) Track the submitter of the wb work to the writeback code.
> 
> Are we going to track the cgroup that originated the dirty pages (or
> maybe dirty inodes) or do you have any idea in particular?
> 

The guy doing the sync(), so that way we can accomplish #3.  But really this is
an implementation detail, however you want to accomplish it is fine by me.

> > 2) Sync() defaults to the root cg, and and it writes all the things as the root
> >    cg.
> 
> OK.
> 
> > 3) Add a flag to the cgroups that would make sync()'ers in that group only be
> >    allowed to write out things that belong to its group.
> 
> So, IIUC, when this flag is enabled a cgroup that is doing sync() would
> trigger the writeback of the pages that belong to that cgroup only and
> it waits only for these pages to be sync-ed, right? In this case
> writeback can still go at cgroup's speed.
> 
> Instead when the flag is disabled, sync() would trigger writeback I/O
> globally, as usual, and it goes at full speed (root cgroup's speed).
> 
> Am I understanding correctly?
> 

Yup that's exactly it.  Thanks,

Josef

