Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDAD6B0038
	for <linux-mm@kvack.org>; Sat,  4 Mar 2017 03:21:51 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 10so67462004pgb.3
        for <linux-mm@kvack.org>; Sat, 04 Mar 2017 00:21:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m8si12850889pln.122.2017.03.04.00.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Mar 2017 00:21:50 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v248Iakd038055
	for <linux-mm@kvack.org>; Sat, 4 Mar 2017 03:21:50 -0500
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28yjp8v0eg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 04 Mar 2017 03:21:49 -0500
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sat, 4 Mar 2017 13:51:47 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 2E7B73940061
	for <linux-mm@kvack.org>; Sat,  4 Mar 2017 13:51:45 +0530 (IST)
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v248LftY11337764
	for <linux-mm@kvack.org>; Sat, 4 Mar 2017 13:51:41 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v248LiBt013950
	for <linux-mm@kvack.org>; Sat, 4 Mar 2017 13:51:44 +0530
Subject: Re: [patch v2] mm, vmstat: print non-populated zones in zoneinfo
References: <alpine.DEB.2.10.1703021525500.5229@chino.kir.corp.google.com>
 <4acf16c5-c64b-b4f8-9a41-1926eed23fe1@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1703031445340.92298@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1703031451310.98023@chino.kir.corp.google.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Sat, 4 Mar 2017 13:51:41 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1703031451310.98023@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d20659a0-dac6-5cbd-9a25-a09d80c6afd4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/04/2017 04:23 AM, David Rientjes wrote:
> Initscripts can use the information (protection levels) from
> /proc/zoneinfo to configure vm.lowmem_reserve_ratio at boot.
> 
> vm.lowmem_reserve_ratio is an array of ratios for each configured zone on
> the system.  If a zone is not populated on an arch, /proc/zoneinfo
> suppresses its output.
> 
> This results in there not being a 1:1 mapping between the set of zones
> emitted by /proc/zoneinfo and the zones configured by
> vm.lowmem_reserve_ratio.
> 
> This patch shows statistics for non-populated zones in /proc/zoneinfo.
> The zones exist and hold a spot in the vm.lowmem_reserve_ratio array.
> Without this patch, it is not possible to determine which index in the
> array controls which zone if one or more zones on the system are not
> populated.
> 
> Remaining users of walk_zones_in_node() are unchanged.  Files such as
> /proc/pagetypeinfo require certain zone data to be initialized properly
> for display, which is not done for unpopulated zones.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
