Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 22EA26B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:57:43 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so15895027pac.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 00:57:42 -0800 (PST)
Received: from out21.biz.mail.alibaba.com (out21.biz.mail.alibaba.com. [205.204.114.132])
        by mx.google.com with ESMTP id la1si1186731pbc.208.2015.11.24.00.57.41
        for <linux-mm@kvack.org>;
        Tue, 24 Nov 2015 00:57:42 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH v2] mm: fix swapped Movable and Reclaimable in /proc/pagetypeinfo
Date: Tue, 24 Nov 2015 16:57:27 +0800
Message-ID: <090401d12696$257883e0$70698ba0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


> Fixes: 016c13daa5c9e4827eca703e2f0621c131f2cca3
> Fixes: 0aaa29a56e4fb0fc9e24edb649e2733a672ca099

The correct format of the tag is
Fixes: commit id ("commit subject")

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
