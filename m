Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id EE9A46B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 06:57:02 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id 127so129711420wmu.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 03:57:02 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id u128si11882318wmb.25.2016.03.31.03.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 03:57:01 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id p65so22526437wmp.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 03:57:01 -0700 (PDT)
Date: Thu, 31 Mar 2016 12:57:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] oom, but there is enough memory
Message-ID: <20160331105700.GD27831@dhcp22.suse.cz>
References: <56FCEAD0.9080806@huawei.com>
 <20160331093011.GC27831@dhcp22.suse.cz>
 <56FCEFFE.6040604@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56FCEFFE.6040604@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 31-03-16 17:38:06, Xishi Qiu wrote:
[...]
> Hi Michal,
> 
> It's arm64, so DMA is [0-4G], and Normal is [4G-]

I wasn't aware of that. Thanks for the clarification.

> Is that something wrong with the RAM hardware, then trigger the problem?

This is hard to tell but I would try to check which of the page fault
path has returned with VM_FAULT_OOM. This might be a wrong .fault
callback.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
