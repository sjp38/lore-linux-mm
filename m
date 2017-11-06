Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA1D6B025F
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:14:44 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j15so5660486wre.15
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:14:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 10si2438546edw.364.2017.11.06.00.14.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 00:14:42 -0800 (PST)
Date: Mon, 6 Nov 2017 09:14:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171106081440.44ixziaqh5ued7zl@dhcp22.suse.cz>
References: <1976258473.140703.1509918992800@email.1und1.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1976258473.140703.1509918992800@email.1und1.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Wahren <stefan.wahren@i2se.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>

On Sun 05-11-17 22:56:32, Stefan Wahren wrote:
> Hi Michal,
> 
> the dwc2 USB driver on BCM2835 in linux-next is affected by the CMA
> allocation issue. A quick web search guide me to your patch, which
> avoid the issue.

Thanks for your testing. Can I assume your Tested-by?

> Since the patch wasn't accepted, i want to know is there another solution?

The patch should be in next-20171106

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
