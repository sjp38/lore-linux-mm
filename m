Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 578E26B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:49:45 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x21so10055943oie.5
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 02:49:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o103si2579791ota.534.2018.03.13.02.49.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Mar 2018 02:49:44 -0700 (PDT)
Date: Tue, 13 Mar 2018 10:49:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: Regarding slabinfo tool generating kernel crash
Message-ID: <20180313094939.GN12772@dhcp22.suse.cz>
References: <20180227135517.GA29402@dhcp22.suse.cz>
 <20180226132235epcms5p2a7d2f362274ffc45198c574057ec82fb@epcms5p2>
 <CGME20180226132235epcms5p2a7d2f362274ffc45198c574057ec82fb@epcms5p1>
 <1923766984.282470.1519888690807.JavaMail.jboss@ep1ml502>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1923766984.282470.1519888690807.JavaMail.jboss@ep1ml502>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gopi Sai Teja <gopi.st@samsung.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ami Prakash Asthana <prakash.a@samsung.com>, Lalit Mohan Tripathi <lalit.mohan@samsung.com>, Himanshu Shukla <himanshu.sh@samsung.com>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>

[Sorry for a late reply]

On Thu 01-03-18 12:48:10, Gopi Sai Teja wrote:
> Hi all,
>  
> Please find the crash logs attached tested on 4.4.0-116-generic #140-Ubuntu.
> How to reproduce:
> 
> Boot the kernel with all slab debug flags enabled(red_zone, poison,
> sanity_checks, store_user)
> 
> and run slabinfo -df.
> 
> For more info, please check the logs.
> If more info required, please let me know

Slabs are corrupted so you should focus on who causes the corruption.
Please work with your distribution support or try to reproduce with the
current upstream kernel to get more help on the kernel mailing list.
Slabtop merely points out the problem.
-- 
Michal Hocko
SUSE Labs
