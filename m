Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 387BF6B04C4
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 15:51:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k68so7029792wmd.14
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:51:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n66si20576197wrb.360.2017.07.27.12.51.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 12:51:14 -0700 (PDT)
Date: Thu, 27 Jul 2017 12:51:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] cpuset: fix a deadlock due to incomplete patching of
 cpusets_enabled()
Message-Id: <20170727125112.5c200880d7580525e24210e3@linux-foundation.org>
In-Reply-To: <20170727164608.12701-1-dmitriyz@waymo.com>
References: <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
	<20170727164608.12701-1-dmitriyz@waymo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dima Zavin <dmitriyz@waymo.com>
Cc: Christopher Lameter <cl@linux.com>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Cliff Spradlin <cspradlin@waymo.com>, Mel Gorman <mgorman@techsingularity.net>

On Thu, 27 Jul 2017 09:46:08 -0700 Dima Zavin <dmitriyz@waymo.com> wrote:

>  - Applied on top of v4.12 since one of the callers in page_alloc.c changed.
>    Still only tested on v4.9.36 and compile tested against v4.12.

That's a problem - this doesn't come close to applying on current
mainline.  I can fix that I guess, but the result should be tested
well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
