Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id F08A86B0031
	for <linux-mm@kvack.org>; Sun, 29 Sep 2013 05:19:39 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so4329235pbc.15
        for <linux-mm@kvack.org>; Sun, 29 Sep 2013 02:19:39 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so4374363pdj.32
        for <linux-mm@kvack.org>; Sun, 29 Sep 2013 02:19:37 -0700 (PDT)
Date: Sun, 29 Sep 2013 17:19:23 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [RFC 0/4] cleancache: SSD backed cleancache backend
Message-ID: <20130929091923.GA376@kernel.org>
References: <20130926141428.392345308@kernel.org>
 <20130926161401.GA3288@medulla.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130926161401.GA3288@medulla.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, bob.liu@oracle.com, dan.magenheimer@oracle.com

On Thu, Sep 26, 2013 at 11:14:01AM -0500, Seth Jennings wrote:
> On Thu, Sep 26, 2013 at 10:14:28PM +0800, Shaohua Li wrote:
> > Hi,
> > 
> > This is a cleancache backend which caches page to disk, usually a SSD. The
> > usage model is similar like Windows readyboost. Eg, user plugs a USB drive,
> > and we use the USB drive to cache clean pages to reduce IO to hard disks.
> 
> Very interesting! A few thoughts:
> 
> It seems that this is doing at the page level what bcache/dm-cache do at
> the block layer.  What is the advantage of doing it this way?

That's true. It's only helpful for case of temporary caching. If a SSD is
dedicated for caching, bcache/dm-cache is always generic.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
