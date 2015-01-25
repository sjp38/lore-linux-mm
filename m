Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1F93E6B0032
	for <linux-mm@kvack.org>; Sun, 25 Jan 2015 09:55:16 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id k48so5111902wev.9
        for <linux-mm@kvack.org>; Sun, 25 Jan 2015 06:55:15 -0800 (PST)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id ci8si14880961wjc.76.2015.01.25.06.55.14
        for <linux-mm@kvack.org>;
        Sun, 25 Jan 2015 06:55:14 -0800 (PST)
Date: Sun, 25 Jan 2015 14:55:18 +0000 (UTC)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Message-ID: <8237170.50348.1422197718126.JavaMail.zimbra@efficios.com>
In-Reply-To: <20141027184809.GW11522@wil.cx>
References: <1254279794.1957.1414240389301.JavaMail.zimbra@efficios.com> <465653369.1985.1414241485934.JavaMail.zimbra@efficios.com> <20141027184809.GW11522@wil.cx>
Subject: Re: Progress on system crash traces with LTTng using DAX and pmem
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, lttng-dev <lttng-dev@lists.lttng.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

----- Original Message -----
> From: "Matthew Wilcox" <willy@linux.intel.com>
> To: "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
> Cc: "Matthew Wilcox" <willy@linux.intel.com>, "Ross Zwisler" <ross.zwisler@linux.intel.com>, "lttng-dev"
> <lttng-dev@lists.lttng.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
> Sent: Monday, October 27, 2014 2:48:09 PM
> Subject: Re: Progress on system crash traces with LTTng using DAX and pmem
> 
> On Sat, Oct 25, 2014 at 12:51:25PM +0000, Mathieu Desnoyers wrote:
> > A quick follow up on my progress on using DAX and pmem with
> > LTTng. I've been able to successfully gather a user-space
> > trace into buffers mmap'd into an ext4 filesystem within
> > a pmem block device mounted with -o dax to bypass the page
> > cache. After a soft reboot, I'm able to mount the partition
> > again, and gather the very last data collected in the buffers
> > by the applications. I created a "lttng-crash" program that
> > extracts data from those buffers and converts the content
> > into a readable Common Trace Format trace. So I guess
> > you have a use-case for your patchsets on commodity hardware
> > right there. :)
> 
> Sweet!
> 
> > I've been asked by my customers if DAX would work well with
> > mtd-ram, which they are using. To you foresee any roadblock
> > with this approach ?
> 
> Looks like we'd need to add support to mtd-blkdevs.c for DAX.  I assume
> they're already using one of the block-based ways to expose MTD to
> filesystems, rather than jffs2/logfs/ubifs?
> 
> I'm thinking we might want to add a flag somewhere in the block_dev / bdi
> that indicates whether DAX is supported.  Currently we rely on whether
> ->direct_access is present in the block_device_operations to indicate
> that, so we'd have to have two block_dev_operations in mtd-blkdevs,
> depending on whether direct access is supported by the underlying
> MTD device.  Not a show-stopper.
> 
> > Please keep me in CC on your next patch versions. I'm willing
> > to spend some more time reviewing them if needed. By the way,
> > do you guys have a target time-frame/kernel version you aim
> > at for getting this work upstream ?
> 
> We're trying to get it upstream ASAP.  We've been working on it
> publically since December last year, and it's getting frustrating that
> it's not upstream already.  I sent a v12 a few minutes before you sent
> this message ...  I thought git would add you to the cc's since your
> Reviewed-by is on some of the patches.

Hi Matthew,

I've noticed that Andrew Morton picked up your DAX patchset, which is
really good news!

About the topic of DAX support on mtd-ram: I'm wonder if we would
need the pmem patchset at all if mtd-ram gets DAX support ? How
do the two approaches differ ? Has anyone tried out mtd-ram over
DAX at this point ?

Thanks for the great work! :)

Mathieu

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
