Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 624426B0338
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 14:21:18 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v60so6751503wrc.7
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 11:21:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si1937990wmp.150.2017.06.22.11.21.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 11:21:17 -0700 (PDT)
Date: Thu, 22 Jun 2017 20:21:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] docs/memory-hotplug: adjust the explanation of
 valid_zones sysfs
Message-ID: <20170622182113.GC19563@dhcp22.suse.cz>
References: <20170622041844.9852-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170622041844.9852-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 22-06-17 12:18:44, Wei Yang wrote:
[...]
> -'valid_zones'     : read-only: designed to show which zones this memory block
> -		    can be onlined to.
> -		    The first column shows it's default zone.
> +'valid_zones'     : read-only: shows different information based on state.
> +		    When state is online, it is designed to show the
> +		    zone name this memory block is onlined to.
> +		    When state is offline, it is designed to show which zones
> +		    this memory block can be onlined to.  The first column
> +		    shows it's default zone.

I do not think we really need to touch this. First of all the last
sentence is not really correct. The ordering of zones doesn't tell which
zone will be onlined by default. This is indeed a change of behavior of
my patch. I am just not sure anybody depends on that. I can fix it up
but again the old semantic was just awkward and I didn't feel like I
should keep it. Also I plan to change this behavior again with planned
patches. I would like to get rid of the non-overlapping zones
restriction so the wording would have to change again.

That being said, let's keep the wording as it is now.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
