Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 58C99828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 08:39:54 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so268953458wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 05:39:54 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id m204si23080690wmf.38.2016.01.11.05.39.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 05:39:53 -0800 (PST)
Received: by mail-wm0-f44.google.com with SMTP id f206so211917346wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 05:39:53 -0800 (PST)
Date: Mon, 11 Jan 2016 14:39:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add ratio in slabinfo print
Message-ID: <20160111133950.GC27317@dhcp22.suse.cz>
References: <56932791.3080502@huawei.com>
 <20160111122553.GB27317@dhcp22.suse.cz>
 <5693AAD5.6090101@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5693AAD5.6090101@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: cl@linux.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, zhong jiang <zhongjiang@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 11-01-16 21:15:01, Xishi Qiu wrote:
> On 2016/1/11 20:25, Michal Hocko wrote:
> 
> > On Mon 11-01-16 11:54:57, Xishi Qiu wrote:
> >> Add ratio(active_objs/num_objs) in /proc/slabinfo, it is used to show
> >> the availability factor in each slab.
> > 
> > What is the reason to add such a new value when it can be trivially
> > calculated from the userspace?
> > 
> > Besides that such a change would break existing parsers no?
> 
> Oh, maybe it is.
> 
> How about adjustment the format because some names are too long?

Parsers should be clever enough to process white spaces properly but
there is no guarantee this will be the case. A more important question
is whether it really makes sense to change this in the first place. What
would be the benefit? Somehow nicer output? Does this justify a potential
breakage of tool processing this file? To me this all sounds like such a
change is not worth it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
