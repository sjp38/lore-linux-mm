Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3258B8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 02:30:29 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 75D0E3EE0AE
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 16:30:18 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5107645DE5B
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 16:30:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 322AB45DE55
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 16:30:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E08BBE08002
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 16:30:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CA34E08001
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 16:30:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [LSF/MM TOPIC][ATTEND]cold page tracking / working set estimation
In-Reply-To: <AANLkTimTSE2OrgFSmsYPk7uW+8zAuwfjbeku8WCbGONP@mail.gmail.com>
References: <AANLkTimTSE2OrgFSmsYPk7uW+8zAuwfjbeku8WCbGONP@mail.gmail.com>
Message-Id: <20110303161550.B959.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Mar 2011 16:30:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lsf-pc@lists.linuxfoundation.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

> Google uses an automated system to assign compute jobs to individual
> machines within a cluster. In order to improve memory utilization in
> the cluster, this system collects memory utilization statistics for
> each cgroup on each machine. The following properties are desired for
> the working set estimation mechanism:
> 
> - Low impact on the normal MM algorithms - we don't want to stress the
> VM just by enabling working set estimation;
> 
> - Collected statistics should be comparable across multiple machines -
> we don't just want to know which cgroup to reclaim from on an
> individual machine, we also need to know which machine is best to
> target a job onto within a large cluster;
> 
> - Low, predictable CPU usage;
> 
> - Among cold pages, differentiate between these that are immediately
> reclaimable and these that would require a disk write.
> 
> We use a very simple approach, scanning memory at a fixed rate and
> identifying pages that haven't been touched in a number of scans. We
> are currently switching from a fakenuma based implementation (which we
> don't think is very upstreamable) to a memcg based one. We think this
> could be of interest to the wider community & would like to discuss
> requirement with other interested folks.

Hi, Michel and Program comittees

I'm not sure what status is MM track. but if this proposal was accepted and
seat number is allowed, I'd like to attend and discuss the issue with other
cloud intersted developers.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
