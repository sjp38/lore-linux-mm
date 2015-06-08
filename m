Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 927856B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 15:35:38 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so111237613pdj.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:35:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ri10si5503056pdb.167.2015.06.08.12.35.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 12:35:37 -0700 (PDT)
Date: Mon, 8 Jun 2015 12:35:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 0/4] idle memory tracking
Message-Id: <20150608123535.d82543cedbb9060612a10113@linux-foundation.org>
In-Reply-To: <CAC4Lta1isOa+OK7mqCDjL+aV1j=mXBA8p5xnrMEMj+jy6dRMaw@mail.gmail.com>
References: <cover.1431437088.git.vdavydov@parallels.com>
	<CAC4Lta1isOa+OK7mqCDjL+aV1j=mXBA8p5xnrMEMj+jy6dRMaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, 7 Jun 2015 11:41:15 +0530 Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com> wrote:

> On Tue, May 12, 2015 at 7:04 PM, Vladimir Davydov
> <vdavydov@parallels.com> wrote:
> > Hi,
> >
> > This patch set introduces a new user API for tracking user memory pages
> > that have not been used for a given period of time. The purpose of this
> > is to provide the userspace with the means of tracking a workload's
> > working set, i.e. the set of pages that are actively used by the
> > workload. Knowing the working set size can be useful for partitioning
> > the system more efficiently, e.g. by tuning memory cgroup limits
> > appropriately, or for job placement within a compute cluster.
> >
> > ---- USE CASES ----
> >
> > The unified cgroup hierarchy has memory.low and memory.high knobs, which
> > are defined as the low and high boundaries for the workload working set
> > size. However, the working set size of a workload may be unknown or
> > change in time. With this patch set, one can periodically estimate the
> > amount of memory unused by each cgroup and tune their memory.low and
> > memory.high parameters accordingly, therefore optimizing the overall
> > memory utilization.
> >
> 
> Hi Vladimir,
> 
> Thanks for the patches, I was able test how the series is helpful to determine
> docker container workingset / idlemem with these patches. (tested on ppc64le
> after porting to a distro kernel).

And what were the results of your testing?  The more details the
better, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
