Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 95B0B6B0255
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 08:55:47 -0500 (EST)
Received: by wmuu63 with SMTP id u63so223421457wmu.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 05:55:47 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id k76si14309893wmg.99.2015.12.09.05.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 05:55:46 -0800 (PST)
Received: by wmec201 with SMTP id c201so74564693wme.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 05:55:45 -0800 (PST)
Date: Wed, 9 Dec 2015 14:55:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: m(un)map kmalloc buffers to userspace
Message-ID: <20151209135544.GE30907@dhcp22.suse.cz>
References: <5667128B.3080704@sigmadesigns.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5667128B.3080704@sigmadesigns.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sebastian_frias@sigmadesigns.com>
Cc: linux-mm@kvack.org, Marc Gonzalez <marc_gonzalez@sigmadesigns.com>, linux-kernel@vger.kernel.org

On Tue 08-12-15 18:25:31, Sebastian Frias wrote:
> Hi,
> 
> We are porting a driver from Linux 3.4.39+ to 4.1.13+, CPU is Cortex-A9.
> 
> The driver maps kmalloc'ed memory to user space.

This sounds like a terrible idea to me. Why don't you simply use the
page allocator directly? Try to imagine what would happen if you mmaped
a kmalloc with a size which is not page aligned? mmaped memory uses
whole page granularity.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
