Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 83A2C6B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 08:07:28 -0500 (EST)
Date: Mon, 18 Jan 2010 21:07:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] sysdev: fix prototype for memory_sysdev_class
	show/store functions
Message-ID: <20100118130702.GB721@localhost>
References: <20100114115956.GA2512@localhost> <20100114120419.GA3538@localhost> <20100114123209.GM12241@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114123209.GM12241@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

> I don't know why Greg didn't merge that one. Greg, did you forget
> some patches?

I guess yes - more than one.
 
> For the record the full series was:
> 
> SYSFS: Pass attribute in sysdev_class attributes show/store
> SYSFS: Convert node driver class attributes to be data driven
> SYSDEV: Convert cpu driver sysdev class attributes 
> SYSFS: Add sysfs_add/remove_files utility functions
> SYSFS: Add attribute array to sysdev classes
> SYSDEV: Convert node driver 
> SYSDEV: Use sysdev_class attribute arrays in node driver
> SYSFS: Add sysdev_create/remove_files
> SYSFS: Fix type of sysdev class attribute in memory driver
> SYSDEV: Add attribute argument to class_attribute show/store
> SYSFS: Add class_attr_string for simple read-only string
> SYSFS: Convert some drivers to CLASS_ATTR_STRING
 
Only the first 3 of them reach linux-next-20100114:

commit 86950fd010b72acf3c7d4ae8c1df440fef09c2b5
Author: Andi Kleen <andi@firstfloor.org>
Date:   Tue Jan 5 12:48:00 2010 +0100

    sysdev: Convert cpu driver sysdev class attributes
    
commit c314abcfb978695949f9314ea9f1b6eea5dbd225
Author: Andi Kleen <andi@firstfloor.org>
Date:   Tue Jan 5 12:47:59 2010 +0100

    sysdev: Convert node driver class attributes to be data driven
    
commit c29af9636774ea95c795b2ddb71e7dc6e50861bf
Author: Andi Kleen <andi@firstfloor.org>
Date:   Tue Jan 5 12:47:58 2010 +0100

    sysdev: Pass attribute in sysdev_class attributes show/store


Others may need resubmission.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
