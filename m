Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 649216B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 12:27:00 -0500 (EST)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nACHJ2IC025362
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 12:19:02 -0500
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nACHQrov087832
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 12:26:53 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nACHSLr2030457
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 10:28:22 -0700
Date: Thu, 12 Nov 2009 09:26:40 -0800
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH v3 1/5] mm: add numa node symlink for memory section in
	sysfs
Message-ID: <20091112172640.GA9320@us.ibm.com>
References: <20091110223154.25636.48462.stgit@bob.kio> <20091110223644.25636.77587.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091110223644.25636.77587.stgit@bob.kio>
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: akpm@linux-foundation.org, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 10, 2009 at 03:36:44PM -0700, Alex Chiang wrote:
> Commit c04fc586c (mm: show node to memory section relationship with
> symlinks in sysfs) created symlinks from nodes to memory sections, e.g.
> 
> /sys/devices/system/node/node1/memory135 -> ../../memory/memory135
> 
> If you're examining the memory section though and are wondering what
> node it might belong to, you can find it by grovelling around in
> sysfs, but it's a little cumbersome.
> 
> Add a reverse symlink for each memory section that points back to the
> node to which it belongs.

Hi Alex,
I'm kinda late to the party but I finally had a chance to review
and try it out on one of our systems today.  Looks good to me.
Tested-by: Gary Hade <garyhade@us.ibm.com>
Acked-by: Gary Hade <garyhade@us.ibm.com>

Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
