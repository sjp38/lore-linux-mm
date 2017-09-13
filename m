Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B05676B0033
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 08:14:35 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d6so12725wrd.7
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 05:14:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p72si1054440wme.267.2017.09.13.05.14.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 05:14:34 -0700 (PDT)
Date: Wed, 13 Sep 2017 14:14:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
Message-ID: <20170913121433.yjzloaf6g447zeq2@dhcp22.suse.cz>
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-2-mhocko@kernel.org>
 <eb5bf356-f498-b430-1ae8-4ff1ad15ad7f@suse.cz>
 <20170911081714.4zc33r7wlj2nnbho@dhcp22.suse.cz>
 <9fad7246-c634-18bb-78f9-b95376c009da@suse.cz>
 <20170913121001.k3a5tkvunmncc5uj@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170913121001.k3a5tkvunmncc5uj@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 13-09-17 14:10:01, Michal Hocko wrote:
> On Wed 13-09-17 13:41:20, Vlastimil Babka wrote:
> > On 09/11/2017 10:17 AM, Michal Hocko wrote:
> [...]
> > > Yes, we should be able to distinguish the two and hopefully we can teach
> > > the migration code to distinguish between EBUSY (likely permanent) and
> > > EGAIN (temporal) failure. This sound like something we should aim for
> > > longterm I guess. Anyway as I've said in other email. If somebody really
> > > wants to have a guaratee of a bounded retry then it is trivial to set up
> > > an alarm and send a signal itself to bail out.
> > 
> > Sure, I would just be careful about not breaking existing userspace
> > (udev?) when offline triggered via ACPI from some management interface
> > (or whatever the exact mechanism is).
> 
> The thing is that there is absolutely no timing guarantee even with
> retry limit in place. We are doing allocations, potentially bouncing on
> locks which can be taken elsewhere etc... So if somebody really depend
> on this then it is pretty much broken already.
> 
> > > Do you think that the changelog should be more clear about this?
> > 
> > It certainly wouldn't hurt :)
> 
> So what do you think about the following wording:

Ups, wrong patch
