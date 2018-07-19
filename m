Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4B116B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:15:56 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d25-v6so6390667qkj.9
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 05:15:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u47-v6sor3084170qtk.139.2018.07.19.05.15.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 05:15:51 -0700 (PDT)
Date: Thu, 19 Jul 2018 08:18:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180719121837.GA13799@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180716155745.10368-1-drake@endlessm.com>
 <20180717112515.GE7193@dhcp22.suse.cz>
 <20180718222157.GG2838@cmpxchg.org>
 <143db4db-2613-345d-9b8e-1794b6d8c4fe@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <143db4db-2613-345d-9b8e-1794b6d8c4fe@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: Michal Hocko <mhocko@kernel.org>, Daniel Drake <drake@endlessm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux@endlessm.com, linux-block@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Thu, Jul 19, 2018 at 01:29:39PM +0200, peter enderborg wrote:
> On 07/19/2018 12:21 AM, Johannes Weiner wrote:
> >
> > Yes, we currently use a userspace application that monitors pressure
> > and OOM kills (there is usually plenty of headroom left for a small
> > application to run by the time quality of service for most workloads
> > has already tanked to unacceptable levels). We want to eventually add
> > this back into the kernel with the appropriate configuration options
> > (pressure threshold value and sustained duration etc.)
> Is that the same application as googles lmkd for android? Any source
> that you might share?

Sure! This is the oomd we've been developing and using at Facebook:

	https://github.com/facebookincubator/oomd
