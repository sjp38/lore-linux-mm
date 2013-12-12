Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 35CC06B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 11:32:25 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so356212eak.11
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 08:32:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si24413010eew.34.2013.12.12.08.32.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 08:32:24 -0800 (PST)
Date: Thu, 12 Dec 2013 17:32:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom
 notifications to access reserves
Message-ID: <20131212163222.GK2630@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com>
 <20131205025026.GA26777@htj.dyndns.org>
 <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
 <20131206190105.GE13373@htj.dyndns.org>
 <alpine.DEB.2.02.1312061441390.8949@chino.kir.corp.google.com>
 <20131210215037.GB9143@htj.dyndns.org>
 <alpine.DEB.2.02.1312101522400.22701@chino.kir.corp.google.com>
 <20131211124240.GA24557@htj.dyndns.org>
 <CAAAKZwsmM-C=kLGV=RW=Y4Mq=BWpQzuPruW6zvEr9p0Xs4GD5g@mail.gmail.com>
 <20131212142156.GB32683@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131212142156.GB32683@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tim Hockin <thockin@hockin.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>

On Thu 12-12-13 09:21:56, Tejun Heo wrote:
[...]
> There'd still be all the bells and whistles to configure and monitor
> system-level OOM and if there's justified need for improvements, we
> surely can and should do that;

You weren't on the CC of the original thread which has started here
https://lkml.org/lkml/2013/11/19/191. And the original request for
discussion was more about user defined _policies_ for the global
OOM rather than user space global OOM handler. I feel that there
are usacases where the current "kill a single task based on some
calculations" is far from optimal which leads to hacks which try to cope
with after oom condition somehow gracefully.

I do agree with you that pulling oom handling sounds too dangerous
even with all the code that it would need and I feel we should go a
different path than (ab)using memcg.oom_control interface for that.
I still think we need to have a way to tell the global OOM killer what
to do.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
