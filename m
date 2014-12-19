Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0239F6B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 16:50:42 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so2380562wgh.40
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 13:50:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cg4si5582859wib.52.2014.12.19.13.50.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Dec 2014 13:50:41 -0800 (PST)
Date: Fri, 19 Dec 2014 13:50:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2] CMA: add the amount of cma memory in meminfo
Message-Id: <20141219135038.6630669170af03914f9d6838@linux-foundation.org>
In-Reply-To: <54938052.3030809@huawei.com>
References: <54938052.3030809@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: m.szyprowski@samsung.com, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, vishnu.ps@samsung.com, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Fri, 19 Dec 2014 09:33:06 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:

> Add the amount of cma memory in the following meminfo.
> /proc/meminfo

We just did this.

> /sys/devices/system/node/nodeXX/meminfo

But not this.

See

commit 47f8f9297d2247d65ee46d8403a73b30f8d0249b
Author: Pintu Kumar <pintu.k@samsung.com>
Date:   Thu Dec 18 16:17:18 2014 -0800

    fs/proc/meminfo.c: include cma info in proc/meminfo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
