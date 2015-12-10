Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id D0E056B025C
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:40:09 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id v187so28627278wmv.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:40:09 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id n123si18949668wmd.67.2015.12.10.03.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:40:07 -0800 (PST)
Received: by wmec201 with SMTP id c201so20821053wme.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:40:07 -0800 (PST)
Date: Thu, 10 Dec 2015 12:40:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: m(un)map kmalloc buffers to userspace
Message-ID: <20151210114005.GF19496@dhcp22.suse.cz>
References: <5667128B.3080704@sigmadesigns.com>
 <20151209135544.GE30907@dhcp22.suse.cz>
 <566835B6.9010605@sigmadesigns.com>
 <20151209143207.GF30907@dhcp22.suse.cz>
 <56684062.9090505@sigmadesigns.com>
 <20151209151254.GH30907@dhcp22.suse.cz>
 <56684A59.7030605@sigmadesigns.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56684A59.7030605@sigmadesigns.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sebastian_frias@sigmadesigns.com>
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 09-12-15 16:35:53, Sebastian Frias wrote:
[...]
> We've seen that drivers/media/pci/zoran/zoran_driver.c for example seems to
> be doing as us kmalloc+remap_pfn_range,

This driver is broken - I will post a patch.

> is there any guarantee (or at least an advised heuristic) to determine
> if a driver is "current" (ie: uses the latest APIs and works)?

OK, it seems I was overly optimistic when directing you to existing
drivers. Sorry about that I wasn't aware you could find such a terrible
code there. Please refer to Linux Device Drivers book which should give
you a much better lead (e.g. http://www.makelinux.net/ldd3/chp-15-sect-2)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
