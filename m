Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A85E6B0007
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:07:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x203-v6so4348535wmg.8
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:07:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18-v6si837283edt.79.2018.06.07.04.07.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jun 2018 04:07:17 -0700 (PDT)
Date: Thu, 7 Jun 2018 13:07:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [4.17 regression] Performance drop on kernel-4.17 visible on
 Stream, Linpack and NAS parallel benchmarks
Message-ID: <20180607110713.GJ32433@dhcp22.suse.cz>
References: <20180606122731.GB27707@jra-laptop.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180606122731.GB27707@jra-laptop.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jakub Racek <jracek@redhat.com>
Cc: linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

[CCing Mel and MM mailing list]

On Wed 06-06-18 14:27:32, Jakub Racek wrote:
> Hi,
> 
> There is a huge performance regression on the 2 and 4 NUMA node systems on
> stream benchmark with 4.17 kernel compared to 4.16 kernel. Stream, Linpack
> and NAS parallel benchmarks show upto 50% performance drop.
> 
> When running for example 20 stream processes in parallel, we see the following behavior:
> 
> * all processes are started at NODE #1
> * memory is also allocated on NODE #1
> * roughly half of the processes are moved to the NODE #0 very quickly. *
> however, memory is not moved to NODE #0 and stays allocated on NODE #1
> 
> As the result, half of the processes are running on NODE#0 with memory being
> still allocated on NODE#1. This leads to non-local memory accesses
> on the high Remote-To-Local Memory Access Ratio on the numatop charts.
> 
> So it seems that 4.17 is not doing a good job to move the memory to the right NUMA
> node after the process has been moved.
> 
> ----8<----
> 
> The above is an excerpt from performance testing on 4.16 and 4.17 kernels.
> 
> For now I'm merely making sure the problem is reported.

Do you have numa balancing enabled?
-- 
Michal Hocko
SUSE Labs
