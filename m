Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 139C36B0033
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 15:17:15 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n8so3245566wmg.4
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 12:17:15 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r12si3643471edb.481.2017.11.06.12.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 12:17:13 -0800 (PST)
Subject: Re: [PATCH] mm, sparse: do not swamp log with huge vmemmap allocation
 failures
References: <20171106092228.31098-1-mhocko@kernel.org>
 <1509992067.4140.1.camel@oracle.com>
 <20171106181835.yfngqffiuwzrjtmu@dhcp22.suse.cz>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <e5e42136-c110-5726-c9e4-966beb7ba015@oracle.com>
Date: Mon, 6 Nov 2017 13:17:02 -0700
MIME-Version: 1.0
In-Reply-To: <20171106181835.yfngqffiuwzrjtmu@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 11/06/2017 11:18 AM, Michal Hocko wrote:
> If we want to make it more sophisticated I would expect some numbers to
> back such a change.
> 

That is reasonable enough.

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
