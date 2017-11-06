Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A429A6B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:46:55 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p75so3289310wmg.2
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:46:55 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.75])
        by mx.google.com with ESMTPS id f5si2040446wrf.288.2017.11.06.00.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 00:46:54 -0800 (PST)
Subject: Re: [1/2] mm: drop migrate type checks from has_unmovable_pages
References: <1976258473.140703.1509918992800@email.1und1.de>
 <20171106081440.44ixziaqh5ued7zl@dhcp22.suse.cz>
From: Stefan Wahren <stefan.wahren@i2se.com>
Message-ID: <ba63643c-e63f-01e5-6013-eea0b4c4ee39@i2se.com>
Date: Mon, 6 Nov 2017 09:46:43 +0100
MIME-Version: 1.0
In-Reply-To: <20171106081440.44ixziaqh5ued7zl@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>

Am 06.11.2017 um 09:14 schrieb Michal Hocko:
> On Sun 05-11-17 22:56:32, Stefan Wahren wrote:
>> Hi Michal,
>>
>> the dwc2 USB driver on BCM2835 in linux-next is affected by the CMA
>> allocation issue. A quick web search guide me to your patch, which
>> avoid the issue.
> Thanks for your testing. Can I assume your Tested-by?

Yes

>
>> Since the patch wasn't accepted, i want to know is there another solution?
> The patch should be in next-20171106
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
