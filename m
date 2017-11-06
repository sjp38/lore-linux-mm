Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE086B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 02:47:08 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y5so11876165pgq.15
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 23:47:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g72si11930308pfg.297.2017.11.05.23.47.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 05 Nov 2017 23:47:07 -0800 (PST)
Subject: Re: [1/2] mm: drop migrate type checks from has_unmovable_pages
References: <1976258473.140703.1509918992800@email.1und1.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4b769fdb-77ed-3d6c-7383-4ae37104363a@suse.cz>
Date: Mon, 6 Nov 2017 08:47:02 +0100
MIME-Version: 1.0
In-Reply-To: <1976258473.140703.1509918992800@email.1und1.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Wahren <stefan.wahren@i2se.com>, Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>

On 11/05/2017 10:56 PM, Stefan Wahren wrote:
> Hi Michal,
> 
> the dwc2 USB driver on BCM2835 in linux-next is affected by the CMA allocation issue. A quick web search guide me to your patch, which avoid the issue.
> 
> Since the patch wasn't accepted, i want to know is there another solution?

AFAIK it was accepted:
http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-drop-migrate-type-checks-from-has_unmovable_pages.patch

So I'd expect it to be in current linux-next as well.

> Is this an issue in dwc2?
> 
> Best regards
> Stefan
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
