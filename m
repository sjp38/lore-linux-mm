Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 18CEC6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 16:05:46 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so1745154pdj.3
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 13:05:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ev1si11681198pbb.294.2014.04.18.13.05.44
        for <linux-mm@kvack.org>;
        Fri, 18 Apr 2014 13:05:45 -0700 (PDT)
Date: Fri, 18 Apr 2014 13:05:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default v2
Message-Id: <20140418130543.8619064c0e5d26cd914c4c3c@linux-foundation.org>
In-Reply-To: <1396945380-18592-1-git-send-email-mgorman@suse.de>
References: <1396945380-18592-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Tue,  8 Apr 2014 09:22:58 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Changelog since v1
>  o topology comment updates
> 
> When it was introduced, zone_reclaim_mode made sense as NUMA distances
> punished and workloads were generally partitioned to fit into a NUMA
> node. NUMA machines are now common but few of the workloads are NUMA-aware
> and it's routine to see major performance due to zone_reclaim_mode being
> enabled but relatively few can identify the problem.
> 
> Those that require zone_reclaim_mode are likely to be able to detect when
> it needs to be enabled and tune appropriately so lets have a sensible
> default for the bulk of users.
> 

This patchset conflicts with  

commit 70ef57e6c22c3323dce179b7d0d433c479266612
Author:     Michal Hocko <mhocko@suse.cz>
AuthorDate: Mon Apr 7 15:37:01 2014 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Mon Apr 7 16:35:50 2014 -0700

    mm: exclude memoryless nodes from zone_reclaim

It was pretty simple to resolve, but please check that I didn't miss
anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
