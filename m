Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2FBE16B026F
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 17:42:13 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id d34so12490664otb.10
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 14:42:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k36-v6si12947864pgb.20.2018.10.31.14.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 14:42:11 -0700 (PDT)
Date: Wed, 31 Oct 2018 22:42:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory_hotplug: cond_resched in __remove_pages
Message-ID: <20181031214208.GA5564@dhcp22.suse.cz>
References: <20181031125840.23982-1-mhocko@kernel.org>
 <20181031121550.2f0cbd10a948880e534beaf7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181031121550.2f0cbd10a948880e534beaf7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@gmail.com>, Johannes Thumshirn <jthumshirn@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 31-10-18 12:15:50, Andrew Morton wrote:
> On Wed, 31 Oct 2018 13:58:40 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > We have received a bug report that unbinding a large pmem (>1TB)
> > can result in a soft lockup:
> > 
> > ...
> >
> > It has been reported on an older (4.12) kernel but the current upstream
> > code doesn't cond_resched in the hot remove code at all and the given
> > range to remove might be really large. Fix the issue by calling cond_resched
> > once per memory section.
> > 
> 
> Worthy of a cc:stable, I suggest?

It is simple enough and we will surely have it in 4.12 based SLES
kernels. So I do not really mind cc: stable.

-- 
Michal Hocko
SUSE Labs
