Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F77F6B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 11:47:32 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so10633530pab.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 08:47:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n79si3775845pfi.15.2016.08.11.08.47.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 08:47:31 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7BFiECB051126
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 11:47:31 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24qm9urrfy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 11:47:30 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 11 Aug 2016 09:47:30 -0600
Date: Thu, 11 Aug 2016 10:47:22 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: mm: Initialise per_cpu_nodestats for all online pgdats at boot
References: <20160804092404.GI2799@techsingularity.net>
 <20160810175940.GA12039@arbab-laptop.austin.ibm.com>
 <20160811092808.GD8119@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20160811092808.GD8119@techsingularity.net>
Message-Id: <20160811154722.GC12039@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mackerras <paulus@ozlabs.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org

On Thu, Aug 11, 2016 at 10:28:08AM +0100, Mel Gorman wrote:
>Fix looks ok. Can you add a proper changelog to it including an example
>oops or do you need me to do it?

Sure, no problem. Patch to follow.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
