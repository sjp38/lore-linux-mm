Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 9110A6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 11:44:06 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 31 Jul 2013 11:44:05 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7B04138C8039
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 11:44:02 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6VFi3qr157232
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 11:44:03 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6VFi10g013910
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 12:44:03 -0300
Date: Wed, 31 Jul 2013 21:13:55 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/10] Improve numa scheduling by consolidating tasks
Message-ID: <20130731154355.GD4880@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1375277624.11541.27.camel@oc6622382223.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1375277624.11541.27.camel@oc6622382223.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Theurer <habanero@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

* Andrew Theurer <habanero@linux.vnet.ibm.com> [2013-07-31 08:33:44]:
>              -----------    -----------    -----------    -----------  
>  VM-node00|   49153(006%)   673792(083%)    51712(006%)   36352(004%) 
> 
> I think the consolidation is a nice concept, but it needs a much tighter
> integration with numa balancing.  The action to clump tasks on same node's
> runqueues should be triggered by detecting that they also access
> the same memory.
> 

Thanks Andrew for testing and reporting your results and analysis.
Will try to focus on getting consolidation + tighter integration with
numa balancing.

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
