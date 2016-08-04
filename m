Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 237E76B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 11:45:56 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id le9so39945019pab.0
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 08:45:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g9si15167912pfk.211.2016.08.04.08.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 08:45:55 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u74FYCAa014323
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 11:45:55 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24kngd6w6k-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 11:45:54 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 09:45:54 -0600
Date: Thu, 4 Aug 2016 10:45:48 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: mm: Initialise per_cpu_nodestats for all online pgdats at boot
References: <20160804092404.GI2799@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20160804092404.GI2799@techsingularity.net>
Message-Id: <20160804154548.GD28305@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mackerras <paulus@ozlabs.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org

On Thu, Aug 04, 2016 at 10:24:04AM +0100, Mel Gorman wrote:
>This has been compile-tested and boot-tested on a 32-bit KVM only. A
>memoryless system was not available to test the patch with. A confirmation
>from Paul and Reza that it resolves their problem is welcome.

Works for me. Thanks, Mel!

Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
