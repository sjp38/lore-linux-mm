Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05C256B03A1
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 04:11:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t23so34641727pfe.17
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 01:11:03 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id e3si16107739plb.171.2017.04.11.01.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 01:11:03 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id a188so3997156pfa.2
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 01:11:03 -0700 (PDT)
Message-ID: <1491898253.8380.2.camel@gmail.com>
Subject: Re: [PATCH 1/9] mm: remove return value from
 init_currently_empty_zone
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 11 Apr 2017 18:10:53 +1000
In-Reply-To: <20170410110351.12215-2-mhocko@kernel.org>
References: <20170410110351.12215-1-mhocko@kernel.org>
	 <20170410110351.12215-2-mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 2017-04-10 at 13:03 +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> init_currently_empty_zone doesn't have any error to return yet it is
> still an int and callers try to be defensive and try to handle potential
> error. Remove this nonsense and simplify all callers.
> 
> This patch shouldn't have any visible effect
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

This makes sense

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
