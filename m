Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id D546F6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:04:49 -0500 (EST)
Received: by obbsd4 with SMTP id sd4so7657813obb.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:04:49 -0800 (PST)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id w184si12851805oiw.32.2015.12.10.04.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 04:04:49 -0800 (PST)
Received: by oigl9 with SMTP id l9so5464521oig.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:04:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151210114005.GF19496@dhcp22.suse.cz>
References: <5667128B.3080704@sigmadesigns.com>
	<20151209135544.GE30907@dhcp22.suse.cz>
	<566835B6.9010605@sigmadesigns.com>
	<20151209143207.GF30907@dhcp22.suse.cz>
	<56684062.9090505@sigmadesigns.com>
	<20151209151254.GH30907@dhcp22.suse.cz>
	<56684A59.7030605@sigmadesigns.com>
	<20151210114005.GF19496@dhcp22.suse.cz>
Date: Thu, 10 Dec 2015 13:04:48 +0100
Message-ID: <CAFLxGvy7z5zo1_9QfYZj1AMLN-+iVnErir_U7=5=y2bRFKHhNQ@mail.gmail.com>
Subject: Re: m(un)map kmalloc buffers to userspace
From: Richard Weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sebastian Frias <sebastian_frias@sigmadesigns.com>, Marc Gonzalez <marc_gonzalez@sigmadesigns.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 10, 2015 at 12:40 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 09-12-15 16:35:53, Sebastian Frias wrote:
> [...]
>> We've seen that drivers/media/pci/zoran/zoran_driver.c for example seems to
>> be doing as us kmalloc+remap_pfn_range,
>
> This driver is broken - I will post a patch.
>
>> is there any guarantee (or at least an advised heuristic) to determine
>> if a driver is "current" (ie: uses the latest APIs and works)?
>
> OK, it seems I was overly optimistic when directing you to existing
> drivers. Sorry about that I wasn't aware you could find such a terrible
> code there. Please refer to Linux Device Drivers book which should give
> you a much better lead (e.g. http://www.makelinux.net/ldd3/chp-15-sect-2)

Also consider using UIO.

-- 
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
