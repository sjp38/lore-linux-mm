Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF616B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 03:06:19 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so54179047wgb.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 00:06:18 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id wp10si624775wjc.164.2015.03.19.00.06.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 00:06:17 -0700 (PDT)
Received: by wixw10 with SMTP id w10so60471248wix.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 00:06:17 -0700 (PDT)
Message-ID: <550A7566.8070907@linaro.org>
Date: Thu, 19 Mar 2015 07:06:14 +0000
From: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCHv3] mm: Don't offset memmap for flatmem
References: <1426291715-16242-1-git-send-email-lauraa@codeaurora.org> <CAJAp7OhebH088EjXxo0tG__p8m11FiNw8qqG6k8eAky6cg2P8g@mail.gmail.com>
In-Reply-To: <CAJAp7OhebH088EjXxo0tG__p8m11FiNw8qqG6k8eAky6cg2P8g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Andersson <bjorn@kryo.se>, Laura Abbott <lauraa@codeaurora.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, ssantosh@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Kevin Hilman <khilman@linaro.org>, Arnd Bergman <arnd@arndb.de>, Stephen Boyd <sboyd@codeaurora.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Kumar Gala <galak@codeaurora.org>



On 19/03/15 00:21, Bjorn Andersson wrote:
>> the memmap array. Just use the allocated memmap without any offset
>> >when running with CONFIG_FLATMEM to avoid the overrun.
>> >
>> >Signed-off-by: Laura Abbott<lauraa@codeaurora.org>
>> >Reported-by: Srinivas Kandagatla<srinivas.kandagatla@linaro.org>
>> >---
> With this I can boot 8960 and 8064 without patching up the MEM ATAGs
> from the bootloader (as well as "reserving" smem).
>
Yes I forgot the mention this I can boot my IFC6410 without the 
fixup.bin ...\o/ .

--srini
> Tested-by: Bjorn Andersson<bjorn.andersson@sonymobile.com>
>
> Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
