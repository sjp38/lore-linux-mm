Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 548806B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 05:52:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p13so970877wmc.6
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 02:52:30 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id e16si4737413edb.427.2018.03.07.02.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 02:52:28 -0800 (PST)
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
From: Igor Stoppa <igor.stoppa@huawei.com>
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-2-igor.stoppa@huawei.com>
 <20180306141047.GB13722@bombadil.infradead.org>
 <6d27845d-a8f3-607b-1b6b-8464de65162c@huawei.com>
Message-ID: <a667773c-59fa-33d1-9621-16e702c1859f@huawei.com>
Date: Wed, 7 Mar 2018 12:51:46 +0200
MIME-Version: 1.0
In-Reply-To: <6d27845d-a8f3-607b-1b6b-8464de65162c@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: david@fromorbit.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 06/03/18 18:05, Igor Stoppa wrote:
> On 06/03/2018 16:10, Matthew Wilcox wrote:

[...]

>> This seems unnecessarily complicated.
> 
> TBH it seemed to me a natural extension of the existing encoding :-)

BTW, to provide some background, this is where it begun:

http://www.openwall.com/lists/kernel-hardening/2017/08/18/4

Probably that comment about "keeping existing behavior and managing two
bitmaps locklessly" is what made me think of growing the 1-bit-per-unit
into a 1-word-per-unit.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
