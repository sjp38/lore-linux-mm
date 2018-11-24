Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C45D56B3396
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 19:08:50 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id o28-v6so6070867pfk.10
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 16:08:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j35si38525470pgl.223.2018.11.23.16.08.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 16:08:49 -0800 (PST)
Date: Fri, 23 Nov 2018 16:08:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: debug: Fix a width vs precision bug in printk
Message-Id: <20181123160846.1160ba23c2514ed9c316be9d@linux-foundation.org>
In-Reply-To: <ddbf19fb-1d73-40ca-b421-4c171466833b@I-love.SAKURA.ne.jp>
References: <20181123072135.gqvblm2vdujbvfjs@kili.mountain>
	<20181123090125.GC8625@dhcp22.suse.cz>
	<20181123143605.GB2970@unbuntlaptop>
	<ddbf19fb-1d73-40ca-b421-4c171466833b@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Michal Hocko <mhocko@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Fri, 23 Nov 2018 23:48:06 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> On 2018/11/23 23:36, Dan Carpenter wrote:
> > On Fri, Nov 23, 2018 at 10:01:25AM +0100, Michal Hocko wrote:
> >> On Fri 23-11-18 10:21:35, Dan Carpenter wrote:
> >>> We had intended to only print dentry->d_name.len characters but there is
> >>> a width vs precision typo so if the name isn't NUL terminated it will
> >>> read past the end of the buffer.
> >>
> >> OK, it took me quite some time to grasp what you mean here. The code
> >> works as expected because d_name.len and dname.name are in sync so there
> >> no spacing going to happen. Anyway what you propose is formally more
> >> correct I guess.
> >>  
> > 
> > Yeah.  If we are sure that the name has a NUL terminator then this
> > change has no effect.
> 
> There seems to be %pd which is designed for printing "struct dentry".

ooh, who knew.  Can we use that please?
