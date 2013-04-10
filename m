Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 0A4D86B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 19:46:24 -0400 (EDT)
Received: by mail-vb0-f52.google.com with SMTP id w8so850649vbf.11
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:46:23 -0700 (PDT)
Message-ID: <5165F9CE.5050600@gmail.com>
Date: Wed, 10 Apr 2013 19:46:22 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/10] Reduce system disruption due to kswapd V2
References: <1365505625-9460-1-git-send-email-mgorman@suse.de> <0000013defd666bf-213d70fc-dfbd-4a50-82ed-e9f4f7391b55-000000@email.amazonses.com> <20130410141445.GD3710@suse.de> <alpine.DEB.2.02.1304101524120.7738@dtop>
In-Reply-To: <alpine.DEB.2.02.1304101524120.7738@dtop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dormando <dormando@rydia.net>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kosaki.motohiro@gmail.com

>> I've never checked it but I would have expected kswapd to stay on the
>> same processor for significant periods of time. Have you experienced
>> problems where kswapd bounces around on CPUs within a node causing
>> workload disruption?
> 
> When kswapd shares the same CPU as our main process it causes a measurable
> drop in response time (graphs show tiny spikes at the same time memory is
> freed). Would be nice to be able to ensure it runs on a different core
> than our latency sensitive processes at least. We can pin processes to
> subsets of cores but I don't think there's a way to keep kswapd from
> waking up on any of them?

You are only talking about extream corner case and don't talk about the other hand.
When number-of-nodes > nubmer-of-cpus, we have no way to avoid cpu sharing. 

Moreover, this is not kswapd specific isssue, every kernel thread makes the same
latency ick. so, this issue should be solved more generic layer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
