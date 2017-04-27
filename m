Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 02B906B02F2
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:17:58 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i137so1160944wmf.19
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 05:17:57 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id p11si2628585wrd.131.2017.04.27.05.17.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 05:17:56 -0700 (PDT)
Subject: Question on ___GFP_NOLOCKDEP - Was: Re: [PATCH 1/1] Remove hardcoding
 of ___GFP_xxx bitmasks
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
 <20170426133549.22603-2-igor.stoppa@huawei.com>
 <20170426144750.GH12504@dhcp22.suse.cz>
 <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <9929419e-c22e-2a9f-a8a6-ad98d5a9da06@huawei.com>
Date: Thu, 27 Apr 2017 15:16:47 +0300
MIME-Version: 1.0
In-Reply-To: <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 26/04/17 18:29, Igor Stoppa wrote:

> On 26/04/17 17:47, Michal Hocko wrote:

[...]

>> Also the current mm tree has ___GFP_NOLOCKDEP which is not addressed
>> here so I suspect you have based your change on the Linus tree.

> I used your tree from kernel.org

I found it, I was using master, instead of auto-latest (is it correct?)
But now I see something that I do not understand (apologies if I'm
asking something obvious).

First there is:

[...]
#define ___GFP_WRITE		0x800000u
#define ___GFP_KSWAPD_RECLAIM	0x1000000u
#ifdef CONFIG_LOCKDEP
#define ___GFP_NOLOCKDEP	0x4000000u
#else
#define ___GFP_NOLOCKDEP	0
#endif

Then:

/* Room for N __GFP_FOO bits */
#define __GFP_BITS_SHIFT (25 + IS_ENABLED(CONFIG_LOCKDEP))



Shouldn't it be either:
___GFP_NOLOCKDEP	0x2000000u

or:

#define __GFP_BITS_SHIFT (25 + 2 * IS_ENABLED(CONFIG_LOCKDEP))


thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
