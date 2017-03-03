Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 134746B0389
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 00:42:16 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f21so116509905pgi.4
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 21:42:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z17si9494038pgi.387.2017.03.02.21.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 21:42:15 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v235cWX3042728
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 00:42:14 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28xs8e5wtm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Mar 2017 00:42:14 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 3 Mar 2017 15:42:11 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id D942D3578065
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 16:42:08 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v235f2cn50266270
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 16:42:07 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v235ebt7028530
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 16:40:37 +1100
Subject: Re: [RFC 00/11] make try_to_unmap simple
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <86c860e4-c53d-200a-f36a-2ed8a7415d5d@linux.vnet.ibm.com>
 <20170303021118.GA3503@bbox>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 3 Mar 2017 11:09:43 +0530
MIME-Version: 1.0
In-Reply-To: <20170303021118.GA3503@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <96e43a6e-182f-2bda-0214-ab3a50946f29@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On 03/03/2017 07:41 AM, Minchan Kim wrote:
> Hi Anshuman,
> 
> On Thu, Mar 02, 2017 at 07:52:27PM +0530, Anshuman Khandual wrote:
>> On 03/02/2017 12:09 PM, Minchan Kim wrote:
>>> Currently, try_to_unmap returns various return value(SWAP_SUCCESS,
>>> SWAP_FAIL, SWAP_AGAIN, SWAP_DIRTY and SWAP_MLOCK). When I look into
>>> that, it's unncessary complicated so this patch aims for cleaning
>>> it up. Change ttu to boolean function so we can remove SWAP_AGAIN,
>>> SWAP_DIRTY, SWAP_MLOCK.
>>
>> It may be a trivial question but apart from being a cleanup does it
>> help in improving it's callers some way ? Any other benefits ?
> 
> If you mean some performace, I don't think so. It just aims for cleanup
> so caller don't need to think much about return value of try_to_unmap.
> What he should consider is just "success/fail". Others will be done in
> isolate/putback friends which makes API simple/easy to use.

Right, got it. Thanks !


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
