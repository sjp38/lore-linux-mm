Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4504E6B0388
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 09:23:41 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 10so9562986pgb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 06:23:41 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h5si7555073pgg.45.2017.03.02.06.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 06:23:40 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v22EJWBm101180
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 09:23:39 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28xdv1mvv7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:23:39 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 3 Mar 2017 00:23:33 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 4B1442BB0057
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 01:23:32 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v22ENOOZ40042564
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 01:23:32 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v22EMx8L003651
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 01:23:00 +1100
Subject: Re: [RFC 00/11] make try_to_unmap simple
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 2 Mar 2017 19:52:27 +0530
MIME-Version: 1.0
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <86c860e4-c53d-200a-f36a-2ed8a7415d5d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On 03/02/2017 12:09 PM, Minchan Kim wrote:
> Currently, try_to_unmap returns various return value(SWAP_SUCCESS,
> SWAP_FAIL, SWAP_AGAIN, SWAP_DIRTY and SWAP_MLOCK). When I look into
> that, it's unncessary complicated so this patch aims for cleaning
> it up. Change ttu to boolean function so we can remove SWAP_AGAIN,
> SWAP_DIRTY, SWAP_MLOCK.

It may be a trivial question but apart from being a cleanup does it
help in improving it's callers some way ? Any other benefits ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
