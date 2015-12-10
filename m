Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3F66B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 08:37:43 -0500 (EST)
Received: by pfu207 with SMTP id 207so48373696pfu.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 05:37:42 -0800 (PST)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.6])
        by mx.google.com with ESMTPS id e25si20455994pfd.29.2015.12.10.05.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 05:37:42 -0800 (PST)
Message-ID: <56698022.1070305@sigmadesigns.com>
Date: Thu, 10 Dec 2015 14:37:38 +0100
From: Sebastian Frias <sebastian_frias@sigmadesigns.com>
MIME-Version: 1.0
Subject: Re: m(un)map kmalloc buffers to userspace
References: <5667128B.3080704@sigmadesigns.com> <20151209135544.GE30907@dhcp22.suse.cz> <566835B6.9010605@sigmadesigns.com> <20151209143207.GF30907@dhcp22.suse.cz> <56684062.9090505@sigmadesigns.com> <20151209151254.GH30907@dhcp22.suse.cz> <56684A59.7030605@sigmadesigns.com> <20151210114005.GF19496@dhcp22.suse.cz>
In-Reply-To: <20151210114005.GF19496@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/10/2015 12:40 PM, Michal Hocko wrote:
> On Wed 09-12-15 16:35:53, Sebastian Frias wrote:
> [...]
>> We've seen that drivers/media/pci/zoran/zoran_driver.c for example seems to
>> be doing as us kmalloc+remap_pfn_range,
>
> This driver is broken - I will post a patch.

Ok, we'll be glad to see a good example, please keep us posted.

>
>> is there any guarantee (or at least an advised heuristic) to determine
>> if a driver is "current" (ie: uses the latest APIs and works)?
>
> OK, it seems I was overly optimistic when directing you to existing
> drivers. Sorry about that I wasn't aware you could find such a terrible
> code there. Please refer to Linux Device Drivers book which should give
> you a much better lead (e.g. http://www.makelinux.net/ldd3/chp-15-sect-2)
>

Thank you for the link.
The current code of our driver was has portions written following LDD3, 
however, we it seems that LDD3 advice is not relevant anymore.
Indeed, it talks about VM_RESERVED, it talks about using "nopage" and it 
says that remap_pfn_range cannot be used for pages from get_user_page 
(or kmalloc).
It seems such assertions are valid on older kernels, because the code 
stops working on 3.4+ if we use remap_pfn_range the same way than 
drivers/media/pci/zoran/zoran_driver.c
However, kmalloc+remap_pfn_range does work on 4.1.13+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
