Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE086B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 11:37:19 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id x13so507148qcv.15
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 08:37:19 -0800 (PST)
Received: from mail-qe0-x22d.google.com (mail-qe0-x22d.google.com [2607:f8b0:400d:c02::22d])
        by mx.google.com with ESMTPS id w7si19347258qeg.0.2013.12.12.08.37.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 08:37:18 -0800 (PST)
Received: by mail-qe0-f45.google.com with SMTP id 6so541590qea.32
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 08:37:18 -0800 (PST)
Date: Thu, 12 Dec 2013 11:37:06 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom
 notifications to access reserves
Message-ID: <20131212163706.GJ32683@htj.dyndns.org>
References: <20131205025026.GA26777@htj.dyndns.org>
 <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
 <20131206190105.GE13373@htj.dyndns.org>
 <alpine.DEB.2.02.1312061441390.8949@chino.kir.corp.google.com>
 <20131210215037.GB9143@htj.dyndns.org>
 <alpine.DEB.2.02.1312101522400.22701@chino.kir.corp.google.com>
 <20131211124240.GA24557@htj.dyndns.org>
 <CAAAKZwsmM-C=kLGV=RW=Y4Mq=BWpQzuPruW6zvEr9p0Xs4GD5g@mail.gmail.com>
 <20131212142156.GB32683@htj.dyndns.org>
 <20131212163222.GK2630@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131212163222.GK2630@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tim Hockin <thockin@hockin.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>

Hello, Michal.

On Thu, Dec 12, 2013 at 05:32:22PM +0100, Michal Hocko wrote:
> You weren't on the CC of the original thread which has started here
> https://lkml.org/lkml/2013/11/19/191. And the original request for
> discussion was more about user defined _policies_ for the global
> OOM rather than user space global OOM handler. I feel that there
> are usacases where the current "kill a single task based on some
> calculations" is far from optimal which leads to hacks which try to cope
> with after oom condition somehow gracefully.
> 
> I do agree with you that pulling oom handling sounds too dangerous
> even with all the code that it would need and I feel we should go a
> different path than (ab)using memcg.oom_control interface for that.
> I still think we need to have a way to tell the global OOM killer what
> to do.

Oh yeah, sure, I have no fundamental objections against improving the
in-kernel system OOM handler, including making it cgroup-aware which
seems like a natural extension to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
