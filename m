Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 26EE76B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 01:48:17 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so22464386pab.7
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 22:48:16 -0800 (PST)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com. [209.85.220.45])
        by mx.google.com with ESMTPS id ah8si4300846pad.214.2015.01.15.22.48.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 22:48:15 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so22485938pab.4
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 22:48:14 -0800 (PST)
Date: Thu, 15 Jan 2015 22:48:12 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: [LSF/MM ATTEND] swap interface improvements
Message-ID: <20150116064812.GA7342@mew>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi,

I would like to attend LSF/MM to discuss future directions for the swap
subsystem. Implementing swapfile support on BTRFS exposed a number of
deficiencies in the swap-over-NFS interface which I've been working on
recently. Additional improvements tie into the kernel AIO discussion.
Christoph also expressed interest in getting rid of the old swap path in
favor of this improved interface at some point in the future, which will
surely get into a bunch of VFS and filesystem-specific issues.

Also of interest: SMR drives, BTRFS, and performance topics.

Thanks!
-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
