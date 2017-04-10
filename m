Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06D0F6B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:43:21 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b87so3031759wmi.14
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:43:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k193si12555092wmg.134.2017.04.10.08.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 08:43:19 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3AFd74V072749
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:43:18 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29r7y6r98r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:43:18 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 10 Apr 2017 09:43:15 -0600
Date: Mon, 10 Apr 2017 10:43:04 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
References: <20170410110351.12215-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170410110351.12215-1-mhocko@kernel.org>
Message-Id: <20170410154304.nnegccpcmivqgevo@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michal Hocko <mhocko@suse.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Mon, Apr 10, 2017 at 01:03:42PM +0200, Michal Hocko wrote:
>This patchset aims at making the onlining semantic more usable. First 
>of all it allows to online memory movable as long as it doesn't clash 
>with the existing ZONE_NORMAL. That means that ZONE_NORMAL and 
>ZONE_MOVABLE cannot overlap. Currently I preserve the original ordering 
>semantic so the zone always precedes the movable zone but I have plans 
>to remove this restriction in future because it is not really 
>necessary.

Thanks for addressing my issues. I see Igor found a few other things to 
square away, but FWIW,

Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
