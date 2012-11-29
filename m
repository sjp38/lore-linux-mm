Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id E67A46B0092
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 18:46:48 -0500 (EST)
Date: Fri, 30 Nov 2012 07:46:13 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [memcg:since-3.6 493/499] include/trace/events/filemap.h:14:1:
 sparse: incompatible types for operation (<)
Message-ID: <50b7f3c5.kjvAZJjuJNxsqjDZ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Jarzmik <robert.jarzmik@free.fr>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
head:   422a0f651b5cefa1b6b3ede2e1c9e540a24a6e01
commit: 07b81da5f80b27543ddbe3164170c64e0941a812 [493/499] mm: trace filemap add and del


sparse warnings:

+ include/trace/events/filemap.h:14:1: sparse: incompatible types for operation (<)
include/trace/events/filemap.h:14:1:    left side has type struct page *<noident>
include/trace/events/filemap.h:14:1:    right side has type int
include/trace/events/filemap.h:45:1: sparse: incompatible types for operation (<)
include/trace/events/filemap.h:45:1:    left side has type struct page *<noident>
include/trace/events/filemap.h:45:1:    right side has type int
include/linux/radix-tree.h:152:16: sparse: incompatible types in comparison expression (different address spaces)
include/linux/radix-tree.h:152:16: sparse: incompatible types in comparison expression (different address spaces)
include/linux/radix-tree.h:152:16: sparse: incompatible types in comparison expression (different address spaces)
include/linux/radix-tree.h:152:16: sparse: incompatible types in comparison expression (different address spaces)

vim +14 include/trace/events/filemap.h

07b81da5 Robert Jarzmik 2012-11-29   1  #undef TRACE_SYSTEM
07b81da5 Robert Jarzmik 2012-11-29   2  #define TRACE_SYSTEM filemap
07b81da5 Robert Jarzmik 2012-11-29   3  
07b81da5 Robert Jarzmik 2012-11-29   4  #if !defined(_TRACE_FILEMAP_H) || defined(TRACE_HEADER_MULTI_READ)
07b81da5 Robert Jarzmik 2012-11-29   5  #define _TRACE_FILEMAP_H
07b81da5 Robert Jarzmik 2012-11-29   6  
07b81da5 Robert Jarzmik 2012-11-29   7  #include <linux/types.h>
07b81da5 Robert Jarzmik 2012-11-29   8  #include <linux/tracepoint.h>
07b81da5 Robert Jarzmik 2012-11-29   9  #include <linux/mm.h>
07b81da5 Robert Jarzmik 2012-11-29  10  #include <linux/memcontrol.h>
07b81da5 Robert Jarzmik 2012-11-29  11  #include <linux/device.h>
07b81da5 Robert Jarzmik 2012-11-29  12  #include <linux/kdev_t.h>
07b81da5 Robert Jarzmik 2012-11-29  13  
07b81da5 Robert Jarzmik 2012-11-29 @14  TRACE_EVENT(mm_filemap_delete_from_page_cache,
07b81da5 Robert Jarzmik 2012-11-29  15  
07b81da5 Robert Jarzmik 2012-11-29  16  	TP_PROTO(struct page *page),
07b81da5 Robert Jarzmik 2012-11-29  17  
07b81da5 Robert Jarzmik 2012-11-29  18  	TP_ARGS(page),
07b81da5 Robert Jarzmik 2012-11-29  19  
07b81da5 Robert Jarzmik 2012-11-29  20  	TP_STRUCT__entry(
07b81da5 Robert Jarzmik 2012-11-29  21  		__field(struct page *, page)
07b81da5 Robert Jarzmik 2012-11-29  22  		__field(unsigned long, i_ino)

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
