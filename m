Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5C706B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 03:58:37 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id dh1so71419454wjb.0
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 00:58:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c29si7719842wrc.303.2017.01.09.00.58.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 00:58:36 -0800 (PST)
Date: Mon, 9 Jan 2017 09:58:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: hugetlb: reservation race leading to under provisioning
Message-ID: <20170109085834.GC7495@dhcp22.suse.cz>
References: <20170105151540.GT21618@dhcp22.suse.cz>
 <a46ad76e-2d73-1138-b871-fc110cc9d596@oracle.com>
 <20170106085808.GE5556@dhcp22.suse.cz>
 <alpine.LNX.2.00.1701061128390.9628@rueplumet.us.cray.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1701061128390.9628@rueplumet.us.cray.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Cassella <cassella@cray.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On Fri 06-01-17 13:57:59, Paul Cassella wrote:
> On Fri, 6 Jan 2017, Michal Hocko wrote:
> > On Thu 05-01-17 16:48:03, Mike Kravetz wrote:
> > > On 01/05/2017 07:15 AM, Michal Hocko wrote:
> 
> > > > we have a customer report on an older kernel (3.12) but I believe the
> > > > same issue is present in the current vanilla kernel. There is a race
> > > > between mmap trying to do a reservation which fails when racing with
> > > > truncate_hugepages. See the reproduced attached.
> > > > 
> > > > It should go like this (analysis come from the customer and I hope I
> > > > haven't screwed their write up).
> 
> Hi Michal,
> 
> There may have been a step missing from what was sent to you, right at the 
> point Mike asked about.  I've added it below.

No, I guess the info I got from you was complete. I was trying to reduce
the info to the minimum and wasn't explicit about this fact enough
assuming it would be clear from the test case which I forgot to add...
Sorry about that!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
