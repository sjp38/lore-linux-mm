Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3622E6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 06:58:21 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so17068776lbb.3
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 03:58:20 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id g1si19096905lbs.32.2015.04.29.03.58.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 03:58:19 -0700 (PDT)
Received: by lbbzk7 with SMTP id zk7so17201574lbb.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 03:58:18 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: Why task_struct slab can't be released back to buddy system?
References: <55408462.6010703@huawei.com>
Date: Wed, 29 Apr 2015 12:58:16 +0200
In-Reply-To: <55408462.6010703@huawei.com> (Zhang Zhen's message of "Wed, 29
	Apr 2015 15:12:34 +0800")
Message-ID: <87fv7j9p6f.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: David Rientjes <rientjes@google.com>, dave.hansen@linux.intel.com, Linux MM <linux-mm@kvack.org>, qiuxishi@huawei.com

On Wed, Apr 29 2015, Zhang Zhen <zhenzhang.zhang@huawei.com> wrote:

> Hi,
>
> Our x86 system has crashed because oom.
> We found task_struct slabs ate much memory.

I can't explain what you've seen, but a simple way to reduce the
memory footprint of struct task_struct is

CONFIG_LATENCYTOP=n

That will reduce sizeof(struct task_struct) by ~3840 bytes (60%, give or
take).

Rasmus

> CACHE    	  NAME                 OBJSIZE  ALLOCATED     TOTAL  SLABS  SSIZE          //**Slabs is much larger than alloctated object counts**
> ffff88081e007500 task_struct             6528       4639    229775  45955    32k

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
