Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 34DD56B0005
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 08:55:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i11so6950952pgq.10
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 05:55:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a6-v6si7535632plm.489.2018.02.27.05.55.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Feb 2018 05:55:21 -0800 (PST)
Date: Tue, 27 Feb 2018 14:55:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Regarding slabinfo tool generating kernel crash
Message-ID: <20180227135517.GA29402@dhcp22.suse.cz>
References: <CGME20180226132235epcms5p2a7d2f362274ffc45198c574057ec82fb@epcms5p2>
 <20180226132235epcms5p2a7d2f362274ffc45198c574057ec82fb@epcms5p2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180226132235epcms5p2a7d2f362274ffc45198c574057ec82fb@epcms5p2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gopi Sai Teja <gopi.st@samsung.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ami Prakash Asthana <prakash.a@samsung.com>, Lalit Mohan Tripathi <lalit.mohan@samsung.com>, Himanshu Shukla <himanshu.sh@samsung.com>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>

On Mon 26-02-18 18:52:35, Gopi Sai Teja wrote:
> Hi all,
> 
> We are using slabinfo tool with -df option. Tool is generating kernel crash.
> Please help if anyone got same issue.
> 
> Our kernel image was built with poison, store_user, red_zone and sanity_checks
> enabled in slab debug.

Such a report is basically pointless without the crash report and the
kernel version which happens to be affected.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
