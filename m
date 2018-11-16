Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4746B095F
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 06:55:41 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id n10-v6so13224161oib.5
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:55:41 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x7si11989310otk.273.2018.11.16.03.55.40
        for <linux-mm@kvack.org>;
        Fri, 16 Nov 2018 03:55:40 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH 0/5] mm, memory_hotplug: improve memory offlining failures
 debugging
References: <20181116083020.20260-1-mhocko@kernel.org>
Message-ID: <8a91e93d-386d-f0bc-d639-a696bb37a34e@arm.com>
Date: Fri, 16 Nov 2018 17:25:35 +0530
MIME-Version: 1.0
In-Reply-To: <20181116083020.20260-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


On 11/16/2018 02:00 PM, Michal Hocko wrote:
> Hi,
> this has been posted as an RFC [1]. I have screwed during rebasing so
> there were few compilation issues in the previous version. I have also
> integrated review feedback from Andrew and Anshuman.
> 
> I have been promissing to improve memory offlining failures debugging
> for quite some time. As things stand now we get only very limited
> information in the kernel log when the offlining fails. It is usually
> only
> [ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-0x8267fffffff] failed
> without no further details. We do not know what exactly fails and for
> what reason. Whenever I was forced to debug such a failure I've always
> had to do a debugging patch to tell me more. We can enable some
> tracepoints but it would be much better to get a better picture without
> using them.
> 
> This patch series does 2 things. The first one is to make dump_page
> more usable by printing more information about the mapping patch 1.
> Then it reduces the log level from emerg to warning so that this
> function is usable from less critical context patch 2. Then I have
> added more detailed information about the offlining failure patch 4
> and finally add dump_page to isolation and offlining migration paths.
> Patch 3 is a trivial cleanup.
> 
> Does this look go to you?
> 
> [1] http://lkml.kernel.org/r/20181107101830.17405-1-mhocko@kernel.org
> 

Agreed. It has been always difficult to debug memory hot plug problems
without a debug patch particularly to understand the unmovable pages
and their isolation failures in the range to be removed. This series
is definitely going to help improve the situation.
