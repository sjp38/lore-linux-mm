Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id CA9A56B004D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 09:50:28 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [RFC PATCH] zcache2 cleanups (s/int/bool + debugfs movement). 
Date: Mon,  5 Nov 2012 09:37:23 -0500
Message-Id: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, ngupta@vflare.org, minchan@kernel.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, gregkh@linuxfoundation.org, devel@driverdev.osuosl.org
Cc: akpm@linux-foundation.org

Looking at the zcache2 code there were a couple of things that I thought
would make sense to move out of the code. For one thing it makes it easier
to read, and for anoter - it can be cleanly compiled out. It also allows
to have a clean seperation of counters that we _need_ vs the optional ones.
Which means that in the future we could get rid of the optional ones.

This patchset is based on the patchset that Dan sent out
(https://lkml.org/lkml/2012/10/31/790). I've stuck
them (and addressed some review comments) and put them in my branch:

 git://git.kernel.org/pub/scm/linux/kernel/git/konrad/mm.git devel/zcache.v3

I am going to repost the module loading some time later this week - Bob Liu had
some comments that I want to address.

So back to this patchset - it fixes some outstanding compile warnings, cleans
up some of the code, and rips out the debug counters out of zcache-main.c
and sticks them in a debug.c file.

I was hoping it would end up with less code, but sadly it ended up with
a bit more due to the empty non-debug functions.

 drivers/staging/ramster/Kconfig       |    8 +
 drivers/staging/ramster/Makefile      |    1 +
 drivers/staging/ramster/debug.c       |   66 ++++++
 drivers/staging/ramster/debug.h       |  225 +++++++++++++++++++
 drivers/staging/ramster/zcache-main.c |  384 ++++++++-------------------------
 5 files changed, 389 insertions(+), 295 deletions(-)

Konrad Rzeszutek Wilk (11):
      zcache2: s/int/bool/ on the various options.
      zcache: Module license is defined twice.
      zcache: Provide accessory functions for counter increase
      zcache: Provide accessory functions for counter decrease.
      zcache: The last of the atomic reads has now an accessory function.
      zcache: Fix compile warnings due to usage of debugfs_create_size_t
      zcache: Make the debug code use pr_debug
      zcache: Move debugfs code out of zcache-main.c file.
      zcache: Use an array to initialize/use debugfs attributes.
      zcache: Move the last of the debugfs counters out
      zcache: Coalesce all debug under CONFIG_ZCACHE2_DEBUG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
