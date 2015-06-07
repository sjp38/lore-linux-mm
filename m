Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id ED3D3900016
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 02:11:17 -0400 (EDT)
Received: by wifx6 with SMTP id x6so54982620wif.0
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 23:11:17 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id ei9si2556137wid.123.2015.06.06.23.11.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jun 2015 23:11:16 -0700 (PDT)
Received: by wibut5 with SMTP id ut5so55215126wib.1
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 23:11:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cover.1431437088.git.vdavydov@parallels.com>
References: <cover.1431437088.git.vdavydov@parallels.com>
Date: Sun, 7 Jun 2015 11:41:15 +0530
Message-ID: <CAC4Lta1isOa+OK7mqCDjL+aV1j=mXBA8p5xnrMEMj+jy6dRMaw@mail.gmail.com>
Subject: Re: [PATCH v5 0/4] idle memory tracking
From: Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com>

On Tue, May 12, 2015 at 7:04 PM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
> Hi,
>
> This patch set introduces a new user API for tracking user memory pages
> that have not been used for a given period of time. The purpose of this
> is to provide the userspace with the means of tracking a workload's
> working set, i.e. the set of pages that are actively used by the
> workload. Knowing the working set size can be useful for partitioning
> the system more efficiently, e.g. by tuning memory cgroup limits
> appropriately, or for job placement within a compute cluster.
>
> ---- USE CASES ----
>
> The unified cgroup hierarchy has memory.low and memory.high knobs, which
> are defined as the low and high boundaries for the workload working set
> size. However, the working set size of a workload may be unknown or
> change in time. With this patch set, one can periodically estimate the
> amount of memory unused by each cgroup and tune their memory.low and
> memory.high parameters accordingly, therefore optimizing the overall
> memory utilization.
>

Hi Vladimir,

Thanks for the patches, I was able test how the series is helpful to determine
docker container workingset / idlemem with these patches. (tested on ppc64le
after porting to a distro kernel).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
