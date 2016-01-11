Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 42472828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:25:56 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id f206so210637353wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:25:56 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id 134si19594187wmr.40.2016.01.11.04.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 04:25:55 -0800 (PST)
Received: by mail-wm0-f54.google.com with SMTP id u188so212180350wmu.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:25:55 -0800 (PST)
Date: Mon, 11 Jan 2016 13:25:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add ratio in slabinfo print
Message-ID: <20160111122553.GB27317@dhcp22.suse.cz>
References: <56932791.3080502@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56932791.3080502@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: cl@linux.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, zhong jiang <zhongjiang@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 11-01-16 11:54:57, Xishi Qiu wrote:
> Add ratio(active_objs/num_objs) in /proc/slabinfo, it is used to show
> the availability factor in each slab.

What is the reason to add such a new value when it can be trivially
calculated from the userspace?

Besides that such a change would break existing parsers no?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
