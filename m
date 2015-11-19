Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E36756B0253
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 23:35:06 -0500 (EST)
Received: by pacej9 with SMTP id ej9so67541654pac.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 20:35:06 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id af1si8972645pad.198.2015.11.18.20.35.05
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 20:35:06 -0800 (PST)
Message-ID: <564D50D0.50607@cn.fujitsu.com>
Date: Thu, 19 Nov 2015 12:32:16 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/5] Make cpuid <-> nodeid mapping persistent.
References: <1447906935-31899-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1447906935-31899-1-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, tj@kernel.org, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com
Cc: tangchen@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

Sorry for the terrible delay for this patch-set.
But unfortunately, they are still not fully tested for the memory-less 
node case.

Please help to review first. Will soon do the tests.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
