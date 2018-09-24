Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id C1CA98E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:42:06 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id 199-v6so9823534wme.1
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 05:42:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n15-v6sor25032950wrm.3.2018.09.24.05.42.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 05:42:05 -0700 (PDT)
Date: Mon, 24 Sep 2018 14:42:03 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: Warning after memory hotplug then online.
Message-ID: <20180924124203.GA4885@techadventures.net>
References: <20180924130701.00006a7b@huawei.com>
 <20180924123917.GA4775@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924123917.GA4775@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linuxarm@huawei.com

On Mon, Sep 24, 2018 at 02:39:17PM +0200, Oscar Salvador wrote:
> On Mon, Sep 24, 2018 at 01:07:01PM +0100, Jonathan Cameron wrote:
> > 
> > Hi All,
> > 
> > This is with some additional patches on top of the mm tree to support
> > arm64 memory hot plug, but this particular issue doesn't (at first glance)
> > seem to be connected to that.  It's not a recent issue as IIRC I
> > disabled Kconfig for cgroups when starting to work on this some time ago
> > as a quick and dirty work around for this.
> 
> Hi Jonathan,
> 
> would you mind to describe the steps you are taking?
> You are adding the memory, and then you online it?

I forgot to ask.
Does this warning only show up with 4.19.0-rc4-mm1-00209-g70dc260f963a, or you can
trigger it with an older version?
Do you happen to know the last one that did not trigger that warning?

Thanks
-- 
Oscar Salvador
SUSE L3
