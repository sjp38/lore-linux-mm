Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA4D76B314C
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 09:36:41 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id v8so10999489ioh.11
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:36:41 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id t134si6288311itf.66.2018.11.23.06.36.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 06:36:40 -0800 (PST)
Date: Fri, 23 Nov 2018 17:36:06 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] mm: debug: Fix a width vs precision bug in printk
Message-ID: <20181123143605.GB2970@unbuntlaptop>
References: <20181123072135.gqvblm2vdujbvfjs@kili.mountain>
 <20181123090125.GC8625@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123090125.GC8625@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Fri, Nov 23, 2018 at 10:01:25AM +0100, Michal Hocko wrote:
> On Fri 23-11-18 10:21:35, Dan Carpenter wrote:
> > We had intended to only print dentry->d_name.len characters but there is
> > a width vs precision typo so if the name isn't NUL terminated it will
> > read past the end of the buffer.
> 
> OK, it took me quite some time to grasp what you mean here. The code
> works as expected because d_name.len and dname.name are in sync so there
> no spacing going to happen. Anyway what you propose is formally more
> correct I guess.
>  

Yeah.  If we are sure that the name has a NUL terminator then this
change has no effect.

regards,
dan carpenter
