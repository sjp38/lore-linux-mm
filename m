Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 62C946B0037
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 16:48:43 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so1953223eei.28
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 13:48:42 -0700 (PDT)
Received: from mycroft.westnet.com (Mycroft.westnet.com. [216.187.52.7])
        by mx.google.com with ESMTPS id u5si41867809een.173.2014.04.18.13.48.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 13:48:41 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <21329.36761.970643.523119@quad.stoffel.home>
Date: Fri, 18 Apr 2014 16:48:25 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default v2
In-Reply-To: <20140418130543.8619064c0e5d26cd914c4c3c@linux-foundation.org>
References: <1396945380-18592-1-git-send-email-mgorman@suse.de>
	<20140418130543.8619064c0e5d26cd914c4c3c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

>>>>> "Andrew" == Andrew Morton <akpm@linux-foundation.org> writes:

Andrew> On Tue,  8 Apr 2014 09:22:58 +0100 Mel Gorman <mgorman@suse.de> wrote:
>> Changelog since v1
>> o topology comment updates
>> 
>> When it was introduced, zone_reclaim_mode made sense as NUMA distances
>> punished and workloads were generally partitioned to fit into a NUMA
>> node. NUMA machines are now common but few of the workloads are NUMA-aware
>> and it's routine to see major performance due to zone_reclaim_mode being
>> enabled but relatively few can identify the problem.


This is unclear here.  "see major performance <what> due" doesn't make
sense to me.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
