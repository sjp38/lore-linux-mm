Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id D800B6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 23:17:13 -0400 (EDT)
Received: by mail-io0-f177.google.com with SMTP id 124so12732084iov.3
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 20:17:13 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0119.hostedemail.com. [216.40.44.119])
        by mx.google.com with ESMTPS id j7si1041403ige.60.2016.03.22.20.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 20:17:13 -0700 (PDT)
Message-ID: <1458703028.22080.7.camel@perches.com>
Subject: Re: [PATCH 4/5] mm/lru: is_file/active_lru can be boolean
From: Joe Perches <joe@perches.com>
Date: Tue, 22 Mar 2016 20:17:08 -0700
In-Reply-To: <1458699969-3432-5-git-send-email-baiyaowei@cmss.chinamobile.com>
References: 
	<1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
	 <1458699969-3432-5-git-send-email-baiyaowei@cmss.chinamobile.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>, akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, rientjes@google.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, kuleshovmail@gmail.com, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2016-03-23 at 10:26 +0800, Yaowei Bai wrote:
> This patch makes is_file/active_lru return bool to improve
> readability due to these particular functions only using either
> one or zero as their return value.
> 
> No functional change.

These assignments to int should likely be modified too

$ git grep -w -n is_file_lru
include/linux/mmzone.h:191:static inline int is_file_lru(enum lru_list lru)
mm/vmscan.c:1404:                                   nr_taken, mode, is_file_lru(lru));
mm/vmscan.c:1525:                       int file = is_file_lru(lru);
mm/vmscan.c:1581:       int file = is_file_lru(lru);
mm/vmscan.c:1783:       int file = is_file_lru(lru);
mm/vmscan.c:1934:       if (is_file_lru(lru))
mm/vmscan.c:2129:                       int file = is_file_lru(lru);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
