Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1AB86B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 07:29:42 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id p3-v6so1797052ljh.19
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:29:42 -0700 (PDT)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id d5-v6si2148966lfb.300.2018.07.19.04.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 04:29:41 -0700 (PDT)
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory, and
 IO v2
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180716155745.10368-1-drake@endlessm.com>
 <20180717112515.GE7193@dhcp22.suse.cz> <20180718222157.GG2838@cmpxchg.org>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <143db4db-2613-345d-9b8e-1794b6d8c4fe@sony.com>
Date: Thu, 19 Jul 2018 13:29:39 +0200
MIME-Version: 1.0
In-Reply-To: <20180718222157.GG2838@cmpxchg.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: Daniel Drake <drake@endlessm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux@endlessm.com, linux-block@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On 07/19/2018 12:21 AM, Johannes Weiner wrote:
>
> Yes, we currently use a userspace application that monitors pressure
> and OOM kills (there is usually plenty of headroom left for a small
> application to run by the time quality of service for most workloads
> has already tanked to unacceptable levels). We want to eventually add
> this back into the kernel with the appropriate configuration options
> (pressure threshold value and sustained duration etc.)
Is that the same application as googles lmkd for android? Any source
that you might share?
