Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEEC6B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 01:19:50 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id k15so11358094lbg.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 22:19:50 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id h123si17704463lfb.126.2016.03.02.22.19.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 22:19:49 -0800 (PST)
Subject: Re: Suspicious error for CMA stress test
References: <56D6F008.1050600@huawei.com> <56D79284.3030009@redhat.com>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <56D7D48C.6010505@huawei.com>
Date: Thu, 3 Mar 2016 14:07:08 +0800
MIME-Version: 1.0
In-Reply-To: <56D79284.3030009@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, Joonsoo Kim <js1304@gmail.com>
Cc: "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Laura,

Thanks a lot for taking a look!

On 2016/3/3 9:25, Laura Abbott wrote:
> (cc -mm and Joonsoo Kim)
>
>
[...]
>
> I played with this a bit and can see the same problem. The sanity
> check of CmaFree < CmaTotal generally triggers in
> __move_zone_freepage_state in unset_migratetype_isolate.
> This also seems to be present as far back as v4.0 which was the
> first version to have the updated accounting from Joonsoo.

Would you mind point out the specific commit ID?

Thanks
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
