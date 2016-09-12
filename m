Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83BCB6B0253
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 01:27:24 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k12so85811188lfb.2
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 22:27:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e69si13698754wmc.143.2016.09.11.22.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Sep 2016 22:27:23 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8C5NArD102453
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 01:27:22 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25ce5wnj7a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 01:27:21 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 12 Sep 2016 15:27:19 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 81F152BB0059
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:27:16 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8C5RGM326476644
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:27:16 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8C5RGTr022302
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:27:16 +1000
Date: Mon, 12 Sep 2016 10:57:14 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4] mm: Add sysfs interface to dump each node's zonelist
 information
References: <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com> <1473302818-23974-1-git-send-email-khandual@linux.vnet.ibm.com> <57D1C914.9090403@intel.com>
In-Reply-To: <57D1C914.9090403@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57D63CB2.8070003@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org

On 09/09/2016 01:54 AM, Dave Hansen wrote:
> On 09/07/2016 07:46 PM, Anshuman Khandual wrote:
>> > after memory or node hot[un]plug is desirable. This change adds one
>> > new sysfs interface (/sys/devices/system/memory/system_zone_details)
>> > which will fetch and dump this information.
> Doesn't this violate the "one value per file" sysfs rule?  Does it
> belong in debugfs instead?

Yeah sure. Will make it a debugfs interface.

> 
> I also really question the need to dump kernel addresses out, filtered
> or not.  What's the point?

Hmm, thought it to be an additional information. But yes its additional
and can be dropped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
