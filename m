Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 340DA8E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:39:21 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id y13-v6so4710880wrh.3
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 05:39:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y6-v6sor25012705wrh.27.2018.09.24.05.39.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 05:39:19 -0700 (PDT)
Date: Mon, 24 Sep 2018 14:39:17 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: Warning after memory hotplug then online.
Message-ID: <20180924123917.GA4775@techadventures.net>
References: <20180924130701.00006a7b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924130701.00006a7b@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linuxarm@huawei.com

On Mon, Sep 24, 2018 at 01:07:01PM +0100, Jonathan Cameron wrote:
> 
> Hi All,
> 
> This is with some additional patches on top of the mm tree to support
> arm64 memory hot plug, but this particular issue doesn't (at first glance)
> seem to be connected to that.  It's not a recent issue as IIRC I
> disabled Kconfig for cgroups when starting to work on this some time ago
> as a quick and dirty work around for this.

Hi Jonathan,

would you mind to describe the steps you are taking?
You are adding the memory, and then you online it?

-- 
Oscar Salvador
SUSE L3
