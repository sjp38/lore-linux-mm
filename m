Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8FF828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 08:40:15 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id f206so211930897wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 05:40:15 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id ld9si198815137wjb.130.2016.01.11.05.40.12
        for <linux-mm@kvack.org>;
        Mon, 11 Jan 2016 05:40:14 -0800 (PST)
Message-ID: <5693AAD5.6090101@huawei.com>
Date: Mon, 11 Jan 2016 21:15:01 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add ratio in slabinfo print
References: <56932791.3080502@huawei.com> <20160111122553.GB27317@dhcp22.suse.cz>
In-Reply-To: <20160111122553.GB27317@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, zhong jiang <zhongjiang@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/1/11 20:25, Michal Hocko wrote:

> On Mon 11-01-16 11:54:57, Xishi Qiu wrote:
>> Add ratio(active_objs/num_objs) in /proc/slabinfo, it is used to show
>> the availability factor in each slab.
> 
> What is the reason to add such a new value when it can be trivially
> calculated from the userspace?
> 
> Besides that such a change would break existing parsers no?

Oh, maybe it is.

How about adjustment the format because some names are too long?

Thanks,
Xishi Qiu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
