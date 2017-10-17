Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC0486B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 01:14:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i124so349982wmf.1
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 22:14:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d203si7247882wme.215.2017.10.16.22.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 22:14:13 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9H5EAZl099776
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 01:14:11 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dnajgj7p9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 01:14:11 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 17 Oct 2017 06:14:01 +0100
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9H5DwDi23265350
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:14:00 GMT
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9H5DwYN027924
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 16:13:58 +1100
Subject: Re: [PATCH] mm, soft_offline: improve hugepage soft offlining error
 log
References: <20171016171757.GA3018@ubuntu-desk-vm>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 17 Oct 2017 10:43:56 +0530
MIME-Version: 1.0
In-Reply-To: <20171016171757.GA3018@ubuntu-desk-vm>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d11b3843-c8b1-457f-27a5-573164789633@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laszlo Toth <laszlth@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On 10/16/2017 10:47 PM, Laszlo Toth wrote:
> On a failed attempt, we get the following entry:
> soft offline: 0x3c0000: migration failed 1, type 17ffffc0008008
> (uptodate|head)
> 
> Make this more specific to be straightforward and to follow
> other error log formats in soft_offline_huge_page().
> 
> Signed-off-by: Laszlo Toth <laszlth@gmail.com>

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
