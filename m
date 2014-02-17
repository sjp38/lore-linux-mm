Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 75AFA6B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 13:34:36 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id v1so14373324yhn.33
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 10:34:36 -0800 (PST)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id w63si16762173yhj.37.2014.02.17.10.34.35
        for <linux-mm@kvack.org>;
        Mon, 17 Feb 2014 10:34:35 -0800 (PST)
Date: Mon, 17 Feb 2014 18:34:28 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
Message-ID: <20140217183428.GA8687@arm.com>
References: <20140216200503.GN30257@n2100.arm.linux.org.uk>
 <20140216214354.GA12947@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140216214354.GA12947@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Sun, Feb 16, 2014 at 04:43:54PM -0500, Theodore Ts'o wrote:
> On Sun, Feb 16, 2014 at 08:05:04PM +0000, Russell King - ARM Linux wrote:
> > I have another machine which OOM'd a week ago with plenty of unused swap
> > - it uses ext3 on raid1 and is a more busy system.  That took 41 days
> > to show, and upon reboot, it got a kernel with kmemleak enabled.  So far,
> > after 7 days, kmemleak has found nothing at all.
> 
> If kmemleak doesn't show anything, then presumably it's not a leak of
> the slab object.  Does /proc/meminfo show anything interesting?  Maybe
> it's a page getting leaked (which wouldn't be noticed by kmemleak)

Kmemleak also doesn't notice leaked objects that are added to a list for
example (still referenced). Maybe /proc/slabinfo would give some clues.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
