Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2F28E6B0035
	for <linux-mm@kvack.org>; Sun, 20 Apr 2014 16:59:32 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so3150634eek.23
        for <linux-mm@kvack.org>; Sun, 20 Apr 2014 13:59:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si51174388een.143.2014.04.20.13.59.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 20 Apr 2014 13:59:30 -0700 (PDT)
Date: Sun, 20 Apr 2014 21:59:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default v2
Message-ID: <20140420205923.GA23991@suse.de>
References: <1396945380-18592-1-git-send-email-mgorman@suse.de>
 <20140418130543.8619064c0e5d26cd914c4c3c@linux-foundation.org>
 <21329.36761.970643.523119@quad.stoffel.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <21329.36761.970643.523119@quad.stoffel.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Fri, Apr 18, 2014 at 04:48:25PM -0400, John Stoffel wrote:
> >>>>> "Andrew" == Andrew Morton <akpm@linux-foundation.org> writes:
> 
> Andrew> On Tue,  8 Apr 2014 09:22:58 +0100 Mel Gorman <mgorman@suse.de> wrote:
> >> Changelog since v1
> >> o topology comment updates
> >> 
> >> When it was introduced, zone_reclaim_mode made sense as NUMA distances
> >> punished and workloads were generally partitioned to fit into a NUMA
> >> node. NUMA machines are now common but few of the workloads are NUMA-aware
> >> and it's routine to see major performance due to zone_reclaim_mode being
> >> enabled but relatively few can identify the problem.
> 
> 
> This is unclear here.  "see major performance <what> due" doesn't make
> sense to me.  
> 

Degradation

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
