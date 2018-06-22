Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28C866B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 17:16:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q8-v6so1559065wmc.2
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 14:16:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i3-v6si7820229wro.408.2018.06.22.14.16.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 14:16:33 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5MLDxpM050814
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 17:16:31 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2js4ef9ac5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 17:16:31 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Fri, 22 Jun 2018 15:16:31 -0600
Date: Fri, 22 Jun 2018 16:16:23 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/4] Small cleanup for memoryhotplug
References: <20180622111839.10071-1-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180622111839.10071-1-osalvador@techadventures.net>
Message-Id: <20180622211622.hwkcrlexjo5ygxns@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, Jonathan.Cameron@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Thu, Jun 21, 2018 at 10:32:58AM +0200, Michal Hocko wrote:
>[Cc Reza Arbab - I remember he was able to hit some bugs in memblock
>registration code when I was reworking that area previously]

Thanks for the heads-up!

I have verified that this patchset doesn't seem to cause any regression 
in the kooky memoryless node use case I was testing.

-- 
Reza Arbab
