Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB996B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:29:42 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id x13so3716350qcv.16
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:29:42 -0800 (PST)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id h93si3858918qgh.4.2014.03.06.13.29.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:29:41 -0800 (PST)
Received: by mail-qg0-f45.google.com with SMTP id j5so8899200qga.4
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:29:41 -0800 (PST)
Date: Thu, 6 Mar 2014 16:29:38 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 00/11] userspace out of memory handling
Message-ID: <20140306212938.GF17902@htj.dyndns.org>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
 <20140306204923.GF14033@htj.dyndns.org>
 <alpine.DEB.2.02.1403061254240.25499@chino.kir.corp.google.com>
 <20140306205911.GG14033@htj.dyndns.org>
 <alpine.DEB.2.02.1403061301020.25499@chino.kir.corp.google.com>
 <20140306211136.GA17902@htj.dyndns.org>
 <alpine.DEB.2.02.1403061312020.25499@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403061312020.25499@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Thu, Mar 06, 2014 at 01:23:57PM -0800, David Rientjes wrote:
> I'm referring to system oom handling as an example above, in case you 
> missed my earlier email a few minutes ago: the previous patchset did not 
> include support for system oom handling.  Nothing that I wrote above was 
> possible with the first patchset.  This is the complete support.

But we were talking about system oom handling.  Yes, the patch didn't
exist back then but the fundamental premises stay unchanged.  There's
no point in restarting the whole thread.  You can refer to this
patchset from that thread.  It's a logical thing to do.  We have all
the context there.  I don't really understand why you're resisting it.
It doesn't change the basis of the discussion.  The issues brought up
before should still be addressed and it only makes sense to retain the
context.

If you have more to add, including the existence of this
implementation, let's please talk in the original thread.  It was long
thread with a lot of points raised.  Let's please not replay that
whole thread here unnecessarily.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
