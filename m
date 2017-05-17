Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 964766B02C4
	for <linux-mm@kvack.org>; Tue, 16 May 2017 21:27:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l73so81366436pfj.8
        for <linux-mm@kvack.org>; Tue, 16 May 2017 18:27:52 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id b78si523836pfe.220.2017.05.16.18.27.50
        for <linux-mm@kvack.org>;
        Tue, 16 May 2017 18:27:51 -0700 (PDT)
Subject: Re: 8 Gigabytes and constantly swapping
References: <171e8fa1-3f14-dc18-09b5-48399b250a30@internode.on.net>
 <20170515080945.GA6062@dhcp22.suse.cz>
From: Arthur Marsh <arthur.marsh@internode.on.net>
Message-ID: <d5cf1dad-00e5-1375-0787-cb9b7813ab3c@internode.on.net>
Date: Wed, 17 May 2017 10:57:47 +0930
MIME-Version: 1.0
In-Reply-To: <20170515080945.GA6062@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org



Michal Hocko wrote on 15/05/17 17:39:

> Is this 32b or 64b kernel? Could you take /proc/vmstat snapshots ever
> second while the kswapd is active?
>

This was with a 64 bit kernel.

Thankfully the problem does not seem to affect 4.12.0-rc1 and later 
kernels, with the amount of swap used and amount of time spent waiting 
on kswapd not being a problem even under heavy load.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
