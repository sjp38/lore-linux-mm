Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A8D9B8E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:54:50 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d13-v6so7216407pln.0
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 05:54:50 -0700 (PDT)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id h9-v6si39133342plk.461.2018.09.24.05.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 05:54:49 -0700 (PDT)
Date: Mon, 24 Sep 2018 13:54:29 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: Warning after memory hotplug then online.
Message-ID: <20180924135429.00007adf@huawei.com>
In-Reply-To: <20180924123917.GA4775@techadventures.net>
References: <20180924130701.00006a7b@huawei.com>
	<20180924123917.GA4775@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linuxarm@huawei.com

On Mon, 24 Sep 2018 14:39:17 +0200
Oscar Salvador <osalvador@techadventures.net> wrote:

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
> 

Yes. Exactly that. 

I've hacked the efi memory map to give me 8GB of memory to play with.
I then use /sys/devices/system/memory/probe to hot add a section and
online via /sys/devices/nodes/devices/node3/memory80/online

Everything 'works', but this warning occurs.

This is with a forward ported version of the first
lot of hotplug patches that Andrea Reale, Maciej Bielski and Scott Branden 
wrote... (with NUMA and ACPI support added).

https://lkml.org/lkml/2017/4/11/536

Jonathan
