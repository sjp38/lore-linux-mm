Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id B27B76B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 02:55:21 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 105so4740170oth.22
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 23:55:21 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id u65si2089328otb.126.2017.11.30.23.55.20
        for <linux-mm@kvack.org>;
        Thu, 30 Nov 2017 23:55:21 -0800 (PST)
Date: Fri, 1 Dec 2017 17:01:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 02/18] vchecker: introduce the valid access checker
Message-ID: <20171201080104.GC21404@js1304-P5Q-DELUXE>
References: <1511855333-3570-3-git-send-email-iamjoonsoo.kim@lge.com>
 <201712011232.cTTDYsy5%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712011232.cTTDYsy5%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>

On Fri, Dec 01, 2017 at 01:08:13PM +0800, kbuild test robot wrote:
> Hi Joonsoo,
> 
> I love your patch! Yet something to improve:

Thanks! I will fix all the error from kbuild bot on next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
