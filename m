Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id C8A236B0006
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 23:07:06 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lb1so1739158pab.5
        for <linux-mm@kvack.org>; Fri, 12 Apr 2013 20:07:05 -0700 (PDT)
Date: Fri, 12 Apr 2013 20:07:03 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH PART3 v3 2/6] staging: ramster: Move debugfs code out of
 ramster.c file
Message-ID: <20130413030703.GA22129@kroah.com>
References: <1365813371-19006-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1365813371-19006-2-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365813371-19006-2-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

On Sat, Apr 13, 2013 at 08:36:06AM +0800, Wanpeng Li wrote:
> Note that at this point there is no CONFIG_RAMSTER_DEBUG
> option in the Kconfig. So in effect all of the counters
> are nop until that option gets introduced in patch:
> ramster/debug: Add CONFIG_RAMSTER_DEBUG Kconfig entry

This patch breaks the build again, so of course, I can't take it:

drivers/built-in.o: In function `ramster_flnode_alloc.isra.5':
ramster.c:(.text+0x1b6a6e): undefined reference to `ramster_flnodes_max'
ramster.c:(.text+0x1b6a7e): undefined reference to `ramster_flnodes_max'
drivers/built-in.o: In function `ramster_count_foreign_pages':
(.text+0x1b7205): undefined reference to `ramster_foreign_pers_pages_max'
drivers/built-in.o: In function `ramster_count_foreign_pages':
(.text+0x1b7215): undefined reference to `ramster_foreign_pers_pages_max'
drivers/built-in.o: In function `ramster_count_foreign_pages':
(.text+0x1b7235): undefined reference to `ramster_foreign_eph_pages_max'
drivers/built-in.o: In function `ramster_count_foreign_pages':
(.text+0x1b7249): undefined reference to `ramster_foreign_eph_pages_max'
drivers/built-in.o: In function `ramster_debugfs_init':
(.init.text+0xd620): undefined reference to `ramster_foreign_eph_pages_max'
drivers/built-in.o: In function `ramster_debugfs_init':
(.init.text+0xd656): undefined reference to `ramster_foreign_pers_pages_max'

I thought you fixed this :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
