Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4836B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 07:24:03 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id u56so4810500wes.9
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 04:24:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j6si9094470wje.154.2014.03.07.04.24.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Mar 2014 04:24:01 -0800 (PST)
Date: Fri, 7 Mar 2014 13:23:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 00/11] userspace out of memory handling
Message-ID: <20140307122359.GA28816@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
 <20140306204923.GF14033@htj.dyndns.org>
 <alpine.DEB.2.02.1403061254240.25499@chino.kir.corp.google.com>
 <20140306205911.GG14033@htj.dyndns.org>
 <alpine.DEB.2.02.1403061301020.25499@chino.kir.corp.google.com>
 <20140306211136.GA17902@htj.dyndns.org>
 <alpine.DEB.2.02.1403061312020.25499@chino.kir.corp.google.com>
 <20140306213324.GG17902@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140306213324.GG17902@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Thu 06-03-14 16:33:24, Tejun Heo wrote:
> A bit of addition.
> 
> On Thu, Mar 06, 2014 at 01:23:57PM -0800, David Rientjes wrote:
> > This patchset provides a solution to a real-world problem that is not 
> > solved with any other patchset.  I expect it to be reviewed as any other 
> > patchset, it's not an "RFC" from my perspective: it's a proposal for 
> > inclusion.  Don't worry, Andrew is not going to apply anything 
> > accidentally.
> 
> I can't force it down your throat but I feel somewhat uneasy about how
> this was posted without any reference to the previous discussion as if
> this were just now being proposed especially as the said discussion
> wasn't particularly favorable to this approach.  Prefixing RFC or at
> least pointing back to the original discussion seems like the
> courteous thing to do.

Completely agreed! My first impression when I saw the patchset yesterday
was that it was posted for sake of future LSF discussion. I was also
curious about the missing RFC. Posting it as a proposal for inclusion is
premature before any conclusion is reached.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
