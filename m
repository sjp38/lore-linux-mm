From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH PART3 v3 2/6] staging: ramster: Move debugfs code out of
 ramster.c file
Date: Sat, 13 Apr 2013 20:52:06 +0800
Message-ID: <37893.9598835588$1365857568@news.gmane.org>
References: <1365813371-19006-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1365813371-19006-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130413030703.GA22129@kroah.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UQzwj-0005Ca-Ju
	for glkm-linux-mm-2@m.gmane.org; Sat, 13 Apr 2013 14:52:45 +0200
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 3EA8F6B0002
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:52:43 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 13 Apr 2013 22:46:36 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 659DD2BB0051
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 22:52:15 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3DCq3sF51904698
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 22:52:10 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3DCq8Ft031280
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 22:52:08 +1000
Content-Disposition: inline
In-Reply-To: <20130413030703.GA22129@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, Apr 12, 2013 at 08:07:03PM -0700, Greg Kroah-Hartman wrote:
>On Sat, Apr 13, 2013 at 08:36:06AM +0800, Wanpeng Li wrote:
>> Note that at this point there is no CONFIG_RAMSTER_DEBUG
>> option in the Kconfig. So in effect all of the counters
>> are nop until that option gets introduced in patch:
>> ramster/debug: Add CONFIG_RAMSTER_DEBUG Kconfig entry
>
>This patch breaks the build again, so of course, I can't take it:
>

Sorry, I don't know why my compiler didn't complain to me. I have
already fixed and repost the patchset.

Regards,
Wanpeng Li 

>drivers/built-in.o: In function `ramster_flnode_alloc.isra.5':
>ramster.c:(.text+0x1b6a6e): undefined reference to `ramster_flnodes_max'
>ramster.c:(.text+0x1b6a7e): undefined reference to `ramster_flnodes_max'
>drivers/built-in.o: In function `ramster_count_foreign_pages':
>(.text+0x1b7205): undefined reference to `ramster_foreign_pers_pages_max'
>drivers/built-in.o: In function `ramster_count_foreign_pages':
>(.text+0x1b7215): undefined reference to `ramster_foreign_pers_pages_max'
>drivers/built-in.o: In function `ramster_count_foreign_pages':
>(.text+0x1b7235): undefined reference to `ramster_foreign_eph_pages_max'
>drivers/built-in.o: In function `ramster_count_foreign_pages':
>(.text+0x1b7249): undefined reference to `ramster_foreign_eph_pages_max'
>drivers/built-in.o: In function `ramster_debugfs_init':
>(.init.text+0xd620): undefined reference to `ramster_foreign_eph_pages_max'
>drivers/built-in.o: In function `ramster_debugfs_init':
>(.init.text+0xd656): undefined reference to `ramster_foreign_pers_pages_max'
>
>I thought you fixed this :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
