Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 205A16B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 04:08:51 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id l66so85922308pfl.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 01:08:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 1si18499728plz.212.2017.03.06.01.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 01:08:50 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2698loN140150
	for <linux-mm@kvack.org>; Mon, 6 Mar 2017 04:08:49 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28yu0pkutm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Mar 2017 04:08:48 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 6 Mar 2017 19:08:40 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 61BA13578056
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 20:08:37 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v2698TE047251674
	for <linux-mm@kvack.org>; Mon, 6 Mar 2017 20:08:37 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v26984bj027475
	for <linux-mm@kvack.org>; Mon, 6 Mar 2017 20:08:04 +1100
Subject: Re: [RFC 01/11] mm: use SWAP_SUCCESS instead of 0
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-2-git-send-email-minchan@kernel.org>
 <e7a05d50-4fa8-66ce-9aa0-df54f21be0d8@linux.vnet.ibm.com>
 <20170303030158.GD3503@bbox>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 6 Mar 2017 14:37:40 +0530
MIME-Version: 1.0
In-Reply-To: <20170303030158.GD3503@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <33a8d76e-dbeb-bcf1-5024-5e780b81bef6@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill@shutemov.name>

On 03/03/2017 08:31 AM, Minchan Kim wrote:
> On Thu, Mar 02, 2017 at 07:57:10PM +0530, Anshuman Khandual wrote:
>> On 03/02/2017 12:09 PM, Minchan Kim wrote:
>>> SWAP_SUCCESS defined value 0 can be changed always so don't rely on
>>> it. Instead, use explict macro.
>>
>> Right. But should not we move the changes to the callers last in the
>> patch series after doing the cleanup to the try_to_unmap() function
>> as intended first.
> 
> I don't understand what you are pointing out. Could you elaborate it
> a bit?

I was just referring to the order of this patch in the series and
thinking if it would have been better if this patch would be at a
later stage in the series. But I guess its okay as we are any way
dropping off SWAP_FAIL, SWAP_SUCCESS etc in the end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
