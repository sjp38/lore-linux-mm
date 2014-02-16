Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id AB48C6B0073
	for <linux-mm@kvack.org>; Sun, 16 Feb 2014 16:44:06 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id t59so13456830yho.8
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 13:44:06 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id p68si11777127yhh.55.2014.02.16.13.44.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sun, 16 Feb 2014 13:44:05 -0800 (PST)
Date: Sun, 16 Feb 2014 16:43:54 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
Message-ID: <20140216214354.GA12947@thunk.org>
References: <20140216200503.GN30257@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140216200503.GN30257@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Sun, Feb 16, 2014 at 08:05:04PM +0000, Russell King - ARM Linux wrote:
> I have another machine which OOM'd a week ago with plenty of unused swap
> - it uses ext3 on raid1 and is a more busy system.  That took 41 days
> to show, and upon reboot, it got a kernel with kmemleak enabled.  So far,
> after 7 days, kmemleak has found nothing at all.

If kmemleak doesn't show anything, then presumably it's not a leak of
the slab object.  Does /proc/meminfo show anything interesting?  Maybe
it's a page getting leaked (which wouldn't be noticed by kmemleak)

       	    	    	   	  	      - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
