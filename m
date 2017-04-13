Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7976B03B1
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 08:03:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 187so3019825wmn.5
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:03:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v63si12823485wma.79.2017.04.13.05.03.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Apr 2017 05:03:28 -0700 (PDT)
Subject: Re: [PATCH 1/9] mm: remove return value from
 init_currently_empty_zone
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a7e71fa9-509a-38a1-d399-1f0f734d9013@suse.cz>
Date: Thu, 13 Apr 2017 14:03:26 +0200
MIME-Version: 1.0
In-Reply-To: <20170410110351.12215-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/10/2017 01:03 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> init_currently_empty_zone doesn't have any error to return yet it is
> still an int and callers try to be defensive and try to handle potential
> error. Remove this nonsense and simplify all callers.
> 
> This patch shouldn't have any visible effect
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
